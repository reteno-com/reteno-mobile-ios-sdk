//
//  AppDelegate.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.09.2022.
//

import SwiftUI
import UserNotifications
import FirebaseCore
import FirebaseMessaging
import Reteno

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    private var applicationFlowCoordinator: ApplicationFlowCoordinator!
    
    private var isRunningTests: Bool {
      NSClassFromString("XCTestCase") != nil
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if isRunningTests {
          window = UIWindow(frame: UIScreen.main.bounds)
          window?.rootViewController = UIViewController()
          window?.makeKeyAndVisible()
          
          return true
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        Reteno.start(apiKey: "SDK_API_KEY", isDebugMode: true)
        Reteno.userNotificationService.willPresentNotificationHandler = { [weak self] notification in
            let alert = InformationAlert(text: "Will present notification:\n\(notification.request.content.userInfo)")
            self?.window?.showInformationAlert(alert)
            
            let authOptions: UNNotificationPresentationOptions
            if #available(iOS 14.0, *) {
                authOptions = [.badge, .sound, .banner]
            } else {
                authOptions = [.badge, .sound, .alert]
            }
            return authOptions
        }
        Reteno.userNotificationService.didReceiveNotificationResponseHandler = { [weak self] response in
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                print("Default action")
                
            case UNNotificationDismissActionIdentifier:
                print("Dismiss action")
                
            default:
                print(response.actionIdentifier)
            }
            
            let alert = InformationAlert(text: "Received response - \(response.actionIdentifier)")
            self?.window?.showInformationAlert(alert)
        }
        Reteno.userNotificationService.notificationActionHandler = { [weak self] userInfo, action in
            let customDataText = action.customData.flatMap { "\nWith custom data: - \($0)" } ?? ""
            let alert = InformationAlert(text: "Received action - \(action.actionId)\(customDataText)")
            self?.window?.showInformationAlert(alert)
        }
        
        Reteno.addLinkHandler { [weak self] url, customData in
            guard
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                components.host == "example-app.esclick.me",
                let linkItem = UniversalLinkItem(rawValue: components.path)
            else {
                if customData != nil {
                    let customDataText = customData.flatMap { "\nWith custom data: - \($0)" } ?? ""
                    let alert = InformationAlert(text: "Received data - \(customDataText)")
                    self?.window?.showInformationAlert(alert)
                }
                // if it's not a deep link, just open Safari
                application.open(url)
                return
            }
            
            self?.applicationFlowCoordinator.handleUniversalLink(linkItem)
        }
        
        Reteno.addInAppStatusHandler { [weak self] inAppMessageStatus in
            switch inAppMessageStatus {
            case .inAppShouldBeDisplayed:
                print("inAppShouldBeDisplayed")
                
            case .inAppIsDisplayed:
                print("inAppIsDisplayed")
                
            case .inAppShouldBeClosed(let action):
                print("\(action)")
            
            case .inAppIsClosed(let action):
                print("\(action)")

            case .inAppReceivedError(let error):
                print("inAppReceivedError")
            }
        }
        
        let window = UIWindow()
        
        applicationFlowCoordinator = ApplicationFlowCoordinator(window: window)
        applicationFlowCoordinator.execute()
        
        self.window = window
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        applicationFlowCoordinator.handleDeeplink(url)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let linkItem = UniversalLinkItem(rawValue: components.path)
        else { return false }
        
        applicationFlowCoordinator.handleUniversalLink(linkItem)
        
        return false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("Device token: ", fcmToken)
        Reteno.userNotificationService.processRemoteNotificationsToken(fcmToken)
    }
    
}
