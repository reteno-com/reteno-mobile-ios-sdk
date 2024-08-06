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
    
    /// The closure will be called only if the application is in the foreground.
    /// If you provide empty UNNotificationPresentationOptions then the notification will not be presented.
    /// The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list.
    /// This decision should be based on whether the information in the notification is otherwise visible to the user.
    public var willPresentNotificationHandler: ((_ notification: UNNotification) -> UNNotificationPresentationOptions)?
    
    /// The closure will be called when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction.
    public var didReceiveNotificationResponseHandler: ((_ response: UNNotificationResponse) -> Void)?
    
    /// The closure will be called when notification is going to be presented if the application is in the foreground.
    /// Also the closure will be called when the user responded to the notification by opening the application,
    /// dismissing the notification or choosing a UNNotificationAction.
    public var didReceiveNotificationUserInfo: ((_ userInfo: [AnyHashable: Any]) -> Void)?
    
    public var notificationActionHandler: ((_ userInfo: [AnyHashable: Any], _ action: RetenoUserNotificationAction) -> Void)?
    
    public static let shared = UserNotificationService()
        
    private override init() {}
    
    // MARK: Notifications register/unregister logic
    
    /// Rgistering application for receiving `Remote notifications`
    /// - Parameter options: Options that determine the authorized features of local and remote notifications.
    /// - Parameter application: Current `UIApplication`. The centralized point of control and coordination for apps running in iOS.
    /// - Parameter userResponse: Closure with user response on permission prompt.
    public func registerForRemoteNotifications(
        with options: UNAuthorizationOptions = [.sound, .alert, .badge],
        application: UIApplication = UIApplication.shared,
        userResponse: ((_ granted: Bool) -> Void)? = nil
    ) {
        let notificationsCenter = UNUserNotificationCenter.current()
        notificationsCenter.requestAuthorization(options: options) { [weak self] granted, error in
            if let error = error {
                Logger.log(error, eventType: .error)
            }
            if granted {
                notificationsCenter.delegate = self
            }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
                userResponse?(granted)
            }
        }
    }
    
    /// Unregistering from receiving `Remote notifications`
    /// - Parameter application: Current `UIApplication`. The centralized point of control and coordination for apps running in iOS.
    public func unregisterFromRemoteNotifications(application: UIApplication = UIApplication.shared) {
        if application.isRegisteredForRemoteNotifications {
            application.unregisterForRemoteNotifications()
            application.applicationIconBadgeNumber = 0
        }
    }
    
    /// Processing device token for receiving `Remote notifications`
    /// - Parameter deviceToken: Registered for device token.
    public func processRemoteNotificationsToken(_ deviceToken: String) {
        let storage = StorageBuilder.build()
        if deviceToken.isEmpty {
            Logger.log("Provided empty token", eventType: .error)
        } else {
            storage.set(value: deviceToken, forKey: StorageKeys.pushToken.rawValue)
        }
        
        RetenoNotificationsHelper.isSubscribedOnNotifications { isSubscribed in
            storage.set(value: isSubscribed, forKey: StorageKeys.isPushSubscribed.rawValue)
            let device = Device(
                externalUserId: ExternalUserIdHelper.getId(),
                phone: ExternalUserDataHelper.getPhone(),
                email: ExternalUserDataHelper.getEmail(),
                isSubscribedOnPush: isSubscribed
            )
            Reteno.upsertDevice(device)
        }
    }
    
    /// Processing opened remote notification
    ///
    /// If there is a link in the notification, it will be handled. Also the notification `CLICKED` status will be tracked.
    ///
    /// - Parameter notification: The notification to which the user responded.
    public func processOpenedRemoteNotification(_ notification: UNNotification) {
        guard let retenoNotification = RetenoUserNotification(userInfo: notification.request.content.userInfo) else { return }
        
        if retenoNotification.isInApp {
            Reteno.inAppMessages().presentInApp(by: retenoNotification.id)
        } else {
            Reteno.updateNotificationInteractionStatus(interactionId: retenoNotification.id, status: .clicked, date: Date())
            let customData = notification.request.content.userInfo as? [String: Any]
            DeepLinksProcessor.processLinks(
                wrappedUrl: retenoNotification.link,
                rawURL: retenoNotification.rawLink,
                customData:  customData,
                isInAppMessageLink: false
            )
        }
    }
    
    /// Processing remote notification response
    /// - Parameter response: Received notification response.
    public func processRemoteNotificationResponse(_ response: UNNotificationResponse) {
        guard let notification = RetenoUserNotification(userInfo: response.notification.request.content.userInfo) else { return }
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            processOpenedRemoteNotification(response.notification)
            
        case UNNotificationDismissActionIdentifier:
            break
            
        default:
            guard !notification.isInApp else {
                Reteno.inAppMessages().presentInApp(by: notification.id)
                return
            }
            
            if let actionButton = notification.actionButtons?.first(where: { $0.actionId == response.actionIdentifier }) {
                Reteno.updateNotificationInteractionStatus(interactionId: notification.id, status: .clicked, date: Date())
                DeepLinksProcessor.processLinks(
                    wrappedUrl: actionButton.link,
                    rawURL: actionButton.rawLink,
                    customData: actionButton.customData,
                    isInAppMessageLink: false
                )
                let action = RetenoUserNotificationAction(
                    actionId: actionButton.actionId,
                    customData: actionButton.customData,
                    link: actionButton.rawLink
                )
                notificationActionHandler?(response.notification.request.content.userInfo, action)
            }
        }
    }
    
    func setNotificationCenterDelegate() {
        guard
            UIApplication.shared.isRegisteredForRemoteNotifications,
            UNUserNotificationCenter.current().delegate.isNone
        else { return }
        
        UNUserNotificationCenter.current().delegate = self
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
        processRemoteNotificationResponse(response)
        didReceiveNotificationResponseHandler?(response)
        didReceiveNotificationUserInfo?(response.notification.request.content.userInfo)
        completionHandler()
    }
    
}
