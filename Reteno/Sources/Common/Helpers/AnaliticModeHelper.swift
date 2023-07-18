//
//  AnalyticModeHelper.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 13.07.2023.
//

import Foundation

struct AnalyticModeHelper {
    
    private init() {}
    
    static func isAnalyticModelOn() -> Bool {
        StorageBuilder.build().getValue(forKey: StorageKeys.analyticModeFlag.rawValue)
    }
    
    static func setIsAnalyticModelOn(_ isOn: Bool) {
        StorageBuilder.build().set(value: isOn, forKey: StorageKeys.analyticModeFlag.rawValue)
    }

}
