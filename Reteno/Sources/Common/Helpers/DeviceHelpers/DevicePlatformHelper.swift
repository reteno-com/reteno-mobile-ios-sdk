//
//  DevicePlatformHelper.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 31.01.2024.
//

import Foundation

public struct DevicePlatformHelper {
    public static func setDevicePlatform(platorm: String) {
        let storage = StorageBuilder.build()
        storage.set(value: platorm, forKey: StorageKeys.devicePlatform.rawValue)
    }
    
    static func getDevicePlatform() -> String {
        StorageBuilder.build().getValue(forKey: StorageKeys.devicePlatform.rawValue) ?? "iOS SDK \(Reteno.version)"
    }
}

