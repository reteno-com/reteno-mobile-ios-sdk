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
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        Reteno.start()
        Reteno.userNotificationService.registerForRemoteNotifications(with: [.sound, .alert, .badge], application: application)
        Reteno.userNotificationService.willPresentNotificationHandler = { notification in
            print("\nContent: ", notification.request.content)
            print("\nUser info: ", notification.request.content.userInfo)
            
            let authOptions: UNNotificationPresentationOptions
            if #available(iOS 14.0, *) {
                authOptions = [.badge, .sound, .banner]
            } else {
                authOptions = [.badge, .sound, .alert]
            }
            return authOptions
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
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("Device token: ", fcmToken)
        Reteno.userNotificationService.processRemoteNotificationsToken(fcmToken)
        let sendingService = SendingServiceBuilder.buildWithApiKey("985CE27D65C43B41B9105A6D4E026241")
        sendingService.createContact(token: fcmToken)
    }
    
}
