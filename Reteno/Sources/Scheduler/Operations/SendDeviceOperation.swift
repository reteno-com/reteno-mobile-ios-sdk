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
    
    init(uuid: String = UUID().uuidString, requestService: MobileRequestService, device: Device, date: Date) {
        self.uuid = uuid
        self.requestService = requestService
        self.device = device
        
        super.init(date: date)
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.upsertDevice(
            externalUserId: device.externalUserId,
            isSubscribedOnPush: device.isSubscribedOnPush
        ) { [weak self] _ in
            self?.finish()
        }
    }
    
}
