//
//  ExternalUserIdHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import Foundation

struct ExternalUserIdHelper {
    
    private init() {}
    
    static func getId() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.externalUserId.rawValue)
    }
    
    static func setId(_ newId: String) {
        StorageBuilder.build().set(value: newId, forKey: StorageKeys.externalUserId.rawValue)
    }
    
}
