//
//  SendDeviceOperation.swift
//  Reteno
//
//  Created by Anna Sahaidak on 21.02.2023.
//

import Foundation

final class SendDeviceOperation: DateOperation, @unchecked Sendable {

    let uuid: String
    let device: Device
    let identity: RequestIdentity
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    
    init(
        uuid: String = UUID().uuidString,
        requestService: MobileRequestService,
        storage: KeyValueStorage,
        device: Device,
        identity: RequestIdentity,
        date: Date
    ) {
        self.uuid = uuid
        self.requestService = requestService
        self.storage = storage
        self.device = device
        self.identity = identity
        
        super.init(date: date)
    }
    
    @available(iOSApplicationExtension, unavailable)
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.pinned(to: identity).upsertDevice(
            externalUserId: device.externalUserId,
            email: device.email,
            phone: device.phone,
            isSubscribedOnPush: device.isSubscribedOnPush
        ) { result in
            /// An upsert for a previous multi-account device id says nothing about the current one.
            guard self.identity.isCurrent else {
                self.finish()
                return
            }
            
            switch result {
            case .success:
                self.storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
                Reteno.inAppMessages().getInAppMessages()
            case .failure:
                self.storage.set(value: false, forKey: StorageKeys.isUpdatedDevice.rawValue)
            }

            self.finish()
        }
    }
    
}
