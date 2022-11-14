//
//  SendUserOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation
import Alamofire

final class SendUserOperation: DateOperation {
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let user: User
    
    init(
        requestService: MobileRequestService = MobileRequestServiceBuilder.buildForDeviceRequest(),
        storage: KeyValueStorage,
        user: User
    ) {
        self.requestService = requestService
        self.storage = storage
        self.user = user
        
        super.init(date: user.date)
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        let updateAttributesResult: (Result<Bool, Error>) -> Void = { [user, unowned self] result in
            guard !self.isCancelled else {
                self.finish()
                
                return
            }
            
            switch result {
            case .success:
                self.storage.clearUser(user)
                if let externalUserId = user.externalUserId {
                    ExternalUserIdHelper.setId(externalUserId)
                }
                self.finish()
                
            case .failure(let failure):
                if let responseCode = (failure as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearUser(user)
                        
                    default:
                        break
                    }
                }
                print(failure.localizedDescription)
                self.cancel()
            }
        }
        
        if let externalUserId = user.externalUserId {
            RetenoNotificationsHelper.isSubscribedOnNotifications { [unowned self] isSubscribed in
                guard !self.isCancelled else {
                    self.finish()
                    
                    return
                }
                
                self.requestService.upsertDevice(
                    externalUserId: externalUserId,
                    isSubscribedOnPush: isSubscribed
                ) { [user, unowned self] result in
                    guard !self.isCancelled else {
                        self.finish()
                        
                        return
                    }
                    
                    switch result {
                    case .success:
                        self.requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
                        
                    case .failure(let failure):
                        if let responseCode = (failure as? AFError)?.responseCode {
                            switch responseCode {
                            case 400...499:
                                self.storage.clearUser(user)
                                
                            default:
                                break
                            }
                        }
                        print(failure.localizedDescription)
                        cancel()
                    }
                }
            }
        } else {
            requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
        }
    }
    
}
