//
//  ApiKeyHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Foundation

struct ApiKeyHelper {
    
    private init() {}
    
    static func getApiKey() -> String {
        StorageBuilder.build().getValue(forKey: StorageKeys.apiKey.rawValue) ?? ""
    }
    
    static func setApiKey(_ apikey: String) {
        StorageBuilder.build().set(value: apikey, forKey: StorageKeys.apiKey.rawValue)
    }
    
}
