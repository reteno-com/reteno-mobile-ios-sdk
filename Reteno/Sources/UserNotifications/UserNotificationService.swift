//
//  UserNotificationService.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UIKit
import UserNotifications

public final class UserNotificationService: NSObject {
    
    public var willPresentNotificationHandler: ((_ notification: UNNotification) -> UNNotificationPresentationOptions)?
    public var didReceiveNotificationResponseHandler: ((_ response: UNNotificationResponse) -> Void)?
    
    var deviceToken: String? {
        StorageBuilder.build().getValue(forKey: StorageKeys.pushToken.rawValue)
    }
    
    public static let shared = UserNotificationService()
        
    private override init() {}
    
    func isRetenoPushNotification(_ content: UNNotificationContent) -> Bool {
        content.userInfo["es_interaction_id"] != nil
    }
    
    // MARK: - Notifications register/unregister logic
    
    public func registerForRemoteNotifications(
        with options: UNAuthorizationOptions = [.sound, .alert, .badge],
        application: UIApplication
    ) {
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.requestAuthorization(options: options) { [weak self] granted, error in
            if let error = error {
                print(error)
            }
            if granted {
                notificationsCenter.delegate = self
            }
            
            notificationsCenter.getNotificationSettings { _ in
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    public func unregisterFromRemoteNotifications(application: UIApplication) {
        if application.isRegisteredForRemoteNotifications {
            application.unregisterForRemoteNotifications()
            application.applicationIconBadgeNumber = 0
        }
    }
    
    public func processRemoteNotificationsToken(_ deviceToken: String) {
        StorageBuilder.build().set(value: deviceToken, forKey: StorageKeys.pushToken.rawValue)
    }
    
}

extension UserNotificationService: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let options: UNNotificationPresentationOptions = {
            guard let options = willPresentNotificationHandler?(notification) else {
                if #available(iOS 14.0, *) {
                    return [.sound, .badge, .banner]
                } else {
                    return [.sound, .badge, .alert]
                }
            }
            
            return options
        }()
        completionHandler(options)
    }
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
            let notification = RetenoUserNotification(userInfo: response.notification.request.content.userInfo) {
            let service = SendingServiceBuilder.build()
            service.updateInteractionStatus(interactionId: notification.id, token: deviceToken ?? "", status: .opened)
        }
        didReceiveNotificationResponseHandler?(response)
        completionHandler()
    }
    
}
