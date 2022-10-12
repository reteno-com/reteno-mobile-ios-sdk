//
//  KeyValueStorage.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 21.09.2022.
//

import Foundation

enum StorageKeys: String {
    
    case pushToken = "com.reteno.push-token.key"
    case deviceId = "com.reteno.device-id.key"
    case externalUserId = "com.reteno.external-user-id.key"
    case apiKey = "com.reteno.api-key.key"
    
}

final class KeyValueStorage {
    
    private let storage = UserDefaults(suiteName:  "group.\(BundleIdHelper.getMainAppBundleId()).reteno-local-storage")
    
    func set(value: String, forKey key: String) {
        guard let storage = storage else {
            preconditionFailure("storage doesn't exist")
        }
        
        storage.setValue(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> String? {
        guard let storage = storage else {
            preconditionFailure("storage doesn't exist")
        }
        
        return storage.string(forKey: key)
    }
    
}
