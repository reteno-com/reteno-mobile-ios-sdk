//
//  SendUserOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation

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
                print(failure.localizedDescription)
                self.cancel()
            }
        }
        
        if let externalUserId = user.externalUserId {
            requestService.upsertDevice(externalUserId: externalUserId) { [user, unowned self] result in
                guard !self.isCancelled else {
                    self.finish()
                    
                    return
                }
                
                switch result {
                case .success:
                    self.requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
                    
                case .failure(let failure):
                    print(failure.localizedDescription)
                    cancel()
                }
            }
        } else {
            requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
        }
    }
    
}
