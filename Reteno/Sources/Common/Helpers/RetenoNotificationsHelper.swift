//
//  RetenoNotificationsHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 26.09.2022.
//

import Foundation
import UserNotifications

struct RetenoNotificationsHelper {
    
    private init() {}
    
    static func isRetenoPushNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        userInfo["es_interaction_id"] != nil
    }
    
    static func deviceToken() -> String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.pushToken.rawValue)
    }
    
    static func isPushSubscribed() -> Bool {
        StorageBuilder.build().getValue(forKey: StorageKeys.isPushSubscribed.rawValue)
    }
    
    static func isSubscribedOnNotifications(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
                
            case .notDetermined, .denied, .ephemeral:
                completion(false)
                
            @unknown default:
                ErrorLogger.shared.capture(
                    error: NotificationAuthorizationStatusError(unsupportedStatus: settings.authorizationStatus)
                )
            }
        }
    }
    
}

// MARK: NotificationAuthorizationStatusError

struct NotificationAuthorizationStatusError: Error {
    
    private let unsupportedStatus: UNAuthorizationStatus
    
    init(unsupportedStatus: UNAuthorizationStatus) {
        self.unsupportedStatus = unsupportedStatus
    }
    
}

extension NotificationAuthorizationStatusError: LocalizedError {
    
    var errorDescription: String? {
        "Unsupported notification authorization status: \(unsupportedStatus.rawValue)"
    }
    
}
