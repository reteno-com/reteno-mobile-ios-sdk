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
    
    static func actualizeDeviceId() {
        guard let id = UIDevice.current.identifierForVendor else { return }
        
        StorageBuilder.build().set(value: id.uuidString, forKey: StorageKeys.deviceId.rawValue)
    }
    
    static func deviceId() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.deviceId.rawValue)
    }
    
}
