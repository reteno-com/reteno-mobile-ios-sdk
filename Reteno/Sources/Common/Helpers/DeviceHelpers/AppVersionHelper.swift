//
//  AppVersionHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 04.10.2022.
//

import Foundation

struct AppVersionHelper {
    
    private init() {}
    
    static func appVersion(from bundle: Bundle = .main) -> String? {
        bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
}
