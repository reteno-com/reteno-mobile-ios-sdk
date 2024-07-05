//
//  File.swift
//  
//
//  Created by Serhii Navka on 01.07.2024.
//

import UserNotifications

private enum AnalyticsPermissionEventKey: String {
    case apnsPermissionAsked = "PushNotificationsPermissionAsked"
}

extension UNUserNotificationCenter {

    @objc
    func swizzledRequestAuthorization(
        options: UNAuthorizationOptions = [],
        completionHandler: @escaping (Bool, (any Error)?) -> Void
    ) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                Reteno.logEvent(
                    eventTypeKey: AnalyticsPermissionEventKey.apnsPermissionAsked.rawValue,
                    parameters: [],
                    forcePush: true
                )
            }
        }
        self.swizzledRequestAuthorization(options: options, completionHandler: completionHandler)
    }
    
    static func swizzleRequestAuthorizationMethod() {
        let originalSelector = #selector(UNUserNotificationCenter.requestAuthorization(options:completionHandler:))
        let swizzledSelector = #selector(UNUserNotificationCenter.swizzledRequestAuthorization(options:completionHandler:))
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        else { return }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
