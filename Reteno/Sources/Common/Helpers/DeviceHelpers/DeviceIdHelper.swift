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
    static func actualizeDeviceId(providedDeviceId: String) {
        guard providedDeviceId != deviceId() else {
            Reteno.inAppMessages().getInAppMessages()
            return
        }
        
        saveDeviceId(providedDeviceId)
        upsertCurrentDevice()
    }
    
    /// Registers the device under the currently stored device id with the currently stored identity
    /// (external user id, email, phone). Callers must have the identity written to storage before calling.
    @available(iOSApplicationExtension, unavailable)
    static func upsertCurrentDevice() {
        let storage = StorageBuilder.build()
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
    
    static func saveDeviceId(_ id: String) {
        StorageBuilder.build().set(value: id, forKey: StorageKeys.deviceId.rawValue)
    }
    
    static func baseDeviceID() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.baseDeviceId.rawValue)
    }
    
    static func saveBaseDeviceId(_ id: String) {
        StorageBuilder.build().set(value: id, forKey: StorageKeys.baseDeviceId.rawValue)
    }
    
}
