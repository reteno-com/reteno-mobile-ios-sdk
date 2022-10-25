//
//  DebugModeHelper.swift
//  
//
//  Created by Anna Sahaidak on 21.10.2022.
//

import Foundation

struct DebugModeHelper {
    
    private init() {}
    
    static func isDebugModeOn() -> Bool {
        StorageBuilder.build().getValue(forKey: StorageKeys.debugModeFlag.rawValue)
    }
    
    static func setIsDebugModeOn(_ isOn: Bool) {
        StorageBuilder.build().set(value: isOn, forKey: StorageKeys.debugModeFlag.rawValue)
    }

}
