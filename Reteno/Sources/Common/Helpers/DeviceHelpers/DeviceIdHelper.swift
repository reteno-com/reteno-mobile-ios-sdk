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
    
    static func actualizeDeviceId(customDeviceId: String? = nil) {
        let storage = StorageBuilder.build()
        
        if let customDeviceId = customDeviceId {
            storage.set(value: customDeviceId, forKey: StorageKeys.customDeviceId.rawValue)
            
            return
        }
        
        guard
            let id = UIDevice.current.identifierForVendor,
            storage.getValue(forKey: StorageKeys.customDeviceId.rawValue).isNone
        else { return }
        
        StorageBuilder.build().set(value: id.uuidString, forKey: StorageKeys.deviceId.rawValue)
    }
    
    static func deviceId() -> String? {
        let storage = StorageBuilder.build()
        
        return storage.getValue(forKey: StorageKeys.customDeviceId.rawValue)
            ?? storage.getValue(forKey: StorageKeys.deviceId.rawValue)
    }
    
}
