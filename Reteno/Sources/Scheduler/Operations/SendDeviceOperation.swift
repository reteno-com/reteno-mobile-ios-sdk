//
//  SendDeviceOperation.swift
//  Reteno
//
//  Created by Anna Sahaidak on 21.02.2023.
//

import Foundation

final class SendDeviceOperation: DateOperation {

    let uuid: String
    let device: Device
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    
    init(
        uuid: String = UUID().uuidString,
        requestService: MobileRequestService,
        storage: KeyValueStorage,
        device: Device,
        date: Date
    ) {
        self.uuid = uuid
        self.requestService = requestService
        self.storage = storage
        self.device = device
        
        super.init(date: date)
    }
    
    @available(iOSApplicationExtension, unavailable)
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.upsertDevice(
            externalUserId: device.externalUserId,
            email: device.email,
            phone: device.phone,
            isSubscribedOnPush: device.isSubscribedOnPush
        ) { [weak self] result in
            guard let self = self else { return }
            
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
