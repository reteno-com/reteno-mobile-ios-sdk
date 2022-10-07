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
        
        Reteno.start(apiKey: "630A66AF-C1D3-4F2A-ACC1-0D51C38D2B05")
        Reteno.userNotificationService.registerForRemoteNotifications(with: [.sound, .alert, .badge], application: application)
        Reteno.userNotificationService.willPresentNotificationHandler = { notification in
            let authOptions: UNNotificationPresentationOptions
            if #available(iOS 14.0, *) {
                authOptions = [.badge, .sound, .banner]
            } else {
                authOptions = [.badge, .sound, .alert]
            }
            return authOptions
        }
        Reteno.userNotificationService.didReceiveNotificationUserInfo = { [weak self] userInfo in
            let alert = InformationAlert(text: "Received user info from push: \n--------\n\(userInfo)")
            self?.window?.showInformationAlert(alert)
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
        let alert = InformationAlert(text: "open url handled: \(url)")
        window?.showInformationAlert(alert)
        
        return true
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("Device token: ", fcmToken)
        Reteno.userNotificationService.processRemoteNotificationsToken(fcmToken)
    }
    
}
