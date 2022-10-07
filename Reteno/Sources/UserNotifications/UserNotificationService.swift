//
//  UserNotificationService.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UIKit
import UserNotifications

@available(iOSApplicationExtension, unavailable)
public final class UserNotificationService: NSObject {
    
    // The closure will be called only if the application is in the foreground.
    // If you provide empty UNNotificationPresentationOptions then the notification will not be presented.
    // The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list.
    // This decision should be based on whether the information in the notification is otherwise visible to the user.
    public var willPresentNotificationHandler: ((_ notification: UNNotification) -> UNNotificationPresentationOptions)?
    
    // The closure will be called when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.
    public var didReceiveNotificationResponseHandler: ((_ response: UNNotificationResponse) -> Void)?
    
    // The closure will be called when notification is going to be presented if the application is in the foreground.
    // Also the closure will be called when the user responded to the notification by opening the application,
    // dismissing the notification or choosing a UNNotificationAction.
    public var didReceiveNotificationUserInfo: ((_ userInfo: [AnyHashable: Any]) -> Void)?
    
    public static let shared = UserNotificationService()
        
    private override init() {}
    
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
        MobileRequestServiceBuilder.build().upsertDevice()
    }
    
}

@available(iOSApplicationExtension, unavailable)
extension UserNotificationService: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        didReceiveNotificationUserInfo?(notification.request.content.userInfo)
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
            
            DeepLinksProcessor.process(notification: notification)
            
            let service = SendingServiceBuilder.build()
            service.updateInteractionStatus(
                interactionId: notification.id,
                token: RetenoNotificationsHelper.deviceToken() ?? "",
                status: .opened
            )
        }
        didReceiveNotificationResponseHandler?(response)
        didReceiveNotificationUserInfo?(response.notification.request.content.userInfo)
        completionHandler()
    }
    
}
