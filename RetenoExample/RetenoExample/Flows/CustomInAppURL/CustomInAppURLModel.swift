//
//  CustomInAppURLModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 02.07.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import Foundation

final class CustomInAppURLModel {
    func updateIsCustomToggle(_ isCustom: Bool) {
        UserDefaults.standard.set(isCustom, forKey: "IsCustomInAppURL")
    }
    
    func save(url: String) {
        UserDefaults.standard.set(url, forKey: "CustomInAppURL")
    }
    
    func getCustomURL() -> String? {
        return UserDefaults.standard.string(forKey: "CustomInAppURL")
    }
    
    func isCustomInAppURL() -> Bool {
        return UserDefaults.standard.bool(forKey: "IsCustomInAppURL")
    }
}
