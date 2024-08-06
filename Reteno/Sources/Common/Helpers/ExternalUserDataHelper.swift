//
//  ExternalUserDataHelper.swift
//  Reteno
//
//  Created by Serhii Navka on 02.08.2024.
//

import Foundation

struct ExternalUserDataHelper {
    
    private init() {}
    
    static func getPhone() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.phoneId.rawValue)
    }
    
    static func setPhone(_ newPhone: String) {
        StorageBuilder.build().set(value: newPhone, forKey: StorageKeys.phoneId.rawValue)
    }
    
    static func getEmail() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.emailId.rawValue)
    }
    
    static func setEmail(_ newEmail: String) {
        StorageBuilder.build().set(value: newEmail, forKey: StorageKeys.emailId.rawValue)
    }
    
}
