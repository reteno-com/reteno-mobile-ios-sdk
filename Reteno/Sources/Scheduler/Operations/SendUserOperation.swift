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
        
        let updateAttributesResult: (Result<Bool, Error>) -> Void = { [user, weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.storage.clearUser(user)
                self.finish()
                
            case .failure(let failure):
                if let responseCode = (failure as? NetworkError)?.statusCode ?? (failure as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearUser(user)
                        
                    default:
                        break
                    }
                }
                self.cancel()
            }
        }
        
        if let externalUserId = user.externalUserId, !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            let infoDeviceRequest = requestService.isEqualDeviceRequest(
                externalUserId: externalUserId,
                email: user.userAttributes?.email,
                phone: user.userAttributes?.phone,
                isSubscribedOnPush: RetenoNotificationsHelper.isPushSubscribed(),
                cachedRequestParams: storage.getCachedDevice()
            )
            if infoDeviceRequest.isEqual {
                requestService.updateUserAttributes(user: self.user, completionHandler: updateAttributesResult)
            } else {
                requestService.upsertDevice(
                    externalUserId: externalUserId,
                    email: user.userAttributes?.email,
                    phone: user.userAttributes?.phone,
                    isSubscribedOnPush: RetenoNotificationsHelper.isPushSubscribed()
                ) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        if self.user.userAttributes.isSome
                            || self.user.subscriptionKeys.isNotEmpty
                            || self.user.groupNamesInclude.isNotEmpty
                            || self.user.groupNamesExclude.isNotEmpty {
                            self.storage.updateCachedDevice(infoDeviceRequest.paramsToSave ?? [:])
                            self.requestService.updateUserAttributes(user: self.user, completionHandler: updateAttributesResult)
                        } else {
                            self.storage.clearUser(self.user)
                            self.finish()
                        }
                        self.storage.updateCachedDevice(infoDeviceRequest.paramsToSave ?? [:])
                        
                    case .failure(let failure):
                        if let responseCode = (failure as? NetworkError)?.statusCode ?? (failure as? AFError)?.responseCode {
                            switch responseCode {
                            case 400...499:
                                self.storage.clearUser(self.user)
                                
                            default:
                                break
                            }
                        }
                        self.cancel()
                    }
                }
            }
        } else {
            requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
        }
    }
    
}
