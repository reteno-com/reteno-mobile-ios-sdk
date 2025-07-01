//
//  CustomDeviceIdModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 26.06.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import Foundation

final class CustomDeviceIdModel {
    
    func updateIsCustomToggle(_ isCustom: Bool) {
        UserDefaults.standard.set(isCustom, forKey: "IsCustomDeviceId")
    }
    
    func generateId() -> String {
        return UUID().uuidString
    }
    
    func save(deviceId: String) {
        UserDefaults.standard.set(deviceId, forKey: "CustomDeviceId")
    }
    
    func getDeviceId() -> String? {
        return UserDefaults.standard.string(forKey: "CustomDeviceId")
    }
    
    func isCustomDeviceId() -> Bool {
        return UserDefaults.standard.bool(forKey: "IsCustomDeviceId")
    }
}
