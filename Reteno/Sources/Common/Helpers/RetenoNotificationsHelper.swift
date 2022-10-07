//
//  RetenoNotificationsHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 26.09.2022.
//

import Foundation

struct RetenoNotificationsHelper {
    
    private init() {}
    
    static func isRetenoPushNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["es_interaction_id"] != nil
    }
    
    static func deviceToken() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.pushToken.rawValue)
    }
    
}
