//
//  SendUserOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation

final class SendUserOperation: DateOperation, @unchecked Sendable {
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let user: User
    
    init(
        requestService: MobileRequestService? = nil,
        storage: KeyValueStorage,
        user: User
    ) {
        self.requestService = requestService ?? MobileRequestServiceBuilder.buildForDeviceRequest(identity: user.identity)
        self.storage = storage
        self.user = user
        
        super.init(date: user.date)
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled, storage.getUsers().contains(where: { $0.id == user.id }) else {
            finish()
            
            return
        }
        
        let updateAttributesResult: (Result<Bool, Error>) -> Void = { [user] result in
            NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
            switch result {
            case .success:
                self.storage.clearUser(user)
                self.finish()
                
            case .failure(let failure):
                if let responseCode = (failure as? APIStatusError)?.statusCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearUser(user)
                        
                    default:
                        break
                    }
                }
                self.cancel()
                self.finish()
            }
        }
        
        /// The cached device describes the current device id; an update left over from a previous
        /// multi-account device id is never compared with it and never overwrites it.
        let isCurrentIdentity = RequestIdentity.resolved(user.identity).isCurrent
        
        if let externalUserId = user.externalUserId, !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            let infoDeviceRequest = requestService.isEqualDeviceRequest(
                externalUserId: externalUserId,
                email: user.userAttributes?.email,
                phone: user.userAttributes?.phone,
                isSubscribedOnPush: RetenoNotificationsHelper.isPushSubscribed(),
                cachedRequestParams: isCurrentIdentity ? storage.getCachedDevice() : nil
            )
            if infoDeviceRequest.isEqual {
                requestService.updateUserAttributes(user: self.user, completionHandler: updateAttributesResult)
            } else {
                requestService.upsertDevice(
                    externalUserId: externalUserId,
                    email: user.userAttributes?.email,
                    phone: user.userAttributes?.phone,
                    isSubscribedOnPush: RetenoNotificationsHelper.isPushSubscribed()
                ) { result in
                    switch result {
                    case .success:
                        if isCurrentIdentity {
                            self.storage.updateCachedDevice(infoDeviceRequest.paramsToSave ?? [:])
                        }
                        if self.user.userAttributes.isSome
                            || self.user.subscriptionKeys.isNotEmpty
                            || self.user.groupNamesInclude.isNotEmpty
                            || self.user.groupNamesExclude.isNotEmpty {
                            self.requestService.updateUserAttributes(user: self.user, completionHandler: updateAttributesResult)
                        } else {
                            self.storage.clearUser(self.user)
                            self.finish()
                        }
                        
                    case .failure(let failure):
                        if let responseCode = (failure as? APIStatusError)?.statusCode {
                            switch responseCode {
                            case 400...499:
                                self.storage.clearUser(self.user)
                                
                            default:
                                break
                            }
                        }
                        self.cancel()
                        self.finish()
                    }
                }
            }
        } else {
            requestService.updateUserAttributes(user: user, completionHandler: updateAttributesResult)
        }
    }
    
}
