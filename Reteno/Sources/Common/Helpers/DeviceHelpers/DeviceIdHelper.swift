//
//  DeviceIdHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import Foundation
import UIKit

struct DeviceIdHelper {
    
    private init() {}
    
    @available(iOSApplicationExtension, unavailable)
    static func actualizeDeviceId() {
        guard let id = UIDevice.current.identifierForVendor, id.uuidString != deviceId() else {
            return
        }
        
        let storage = StorageBuilder.build()
        storage.set(value: id.uuidString, forKey: StorageKeys.deviceId.rawValue)
        RetenoNotificationsHelper.isSubscribedOnNotifications { isSubscribed in
            storage.set(value: isSubscribed, forKey: StorageKeys.isPushSubscribed.rawValue)
            let device = Device(
                externalUserId: ExternalUserIdHelper.getId(),
                phone: ExternalUserDataHelper.getPhone(),
                email: ExternalUserDataHelper.getEmail(),
                isSubscribedOnPush: isSubscribed
            )
            Reteno.upsertDevice(device)
        }
    }
    
    static func deviceId() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.deviceId.rawValue)
    }
    
}
