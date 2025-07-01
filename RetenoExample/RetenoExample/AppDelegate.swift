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
    
    let userDefaults: UserDefaults = .standard
    
    var window: UIWindow?
    private var applicationFlowCoordinator: ApplicationFlowCoordinator!
    
    private var isRunningTests: Bool {
      NSClassFromString("XCTestCase") != nil
    }
    
    var apiKey: String = "SDK_API_KEY"
    
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
        
        if isDelayedInitalizationForTest {
            Reteno.delayedStart()
        } else {
            let configuration: RetenoConfiguration = .init(isAutomaticScreenReportingEnabled: true,
                                                           isAutomaticAppLifecycleReportingEnabled: true,
                                                           isDebugMode: true,
                                                           useCustomDeviceId: isCustomDeviceIdProviderEnabled)
            Reteno.start(apiKey: apiKey,
                         configuration: configuration)
            if isCustomDeviceIdProviderEnabled {
                provideCustomDeviceId()
            }
        }

        Reteno.userNotificationService.willPresentNotificationHandler = { [weak self] notification in
            let alert = InformationAlert(
                text: "Will present notification:\n\(notification.request.content.userInfo)",
                backgroundType: .push
            )
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
            
            let alert = InformationAlert(
                text: "Received response - \(response.actionIdentifier)",
                backgroundType: .push
            )
            self?.window?.showInformationAlert(alert)
        }
        Reteno.userNotificationService.notificationActionHandler = { [weak self] userInfo, action in
            let customDataText = action.customData.flatMap { "\nWith custom data: - \($0)" } ?? ""
            let alert = InformationAlert(
                text: "Received action - \(action.actionId)\(customDataText)",
                backgroundType: .push
            )
            self?.window?.showInformationAlert(alert)
        }
        
        Reteno.addLinkHandler { [weak self] linkInfo in
            guard
                let url = linkInfo.url,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                components.host == "example-app.esclick.me",
                let linkItem = UniversalLinkItem(rawValue: components.path)
            else {
                if linkInfo.customData != nil {
                    var customDataText = linkInfo.customData.flatMap { "\nWith custom data: - \($0)" } ?? ""
                    switch linkInfo.source {
                    case .inAppMessage:
                        customDataText += " - inApp"
                    case .pushNotification:
                        customDataText += " - push"
                    }
                    let urlString = linkInfo.url?.absoluteString ?? "null"
                    let alert = InformationAlert(
                        text: "Url: \(urlString),\nReceived data - \(customDataText)",
                        backgroundType: linkInfo.source.toBackground
                    )
                    self?.window?.showInformationAlert(alert)
                }
                
                if let url = linkInfo.url {
                    // delay for see response alert on device (used for testing)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // if it's not a deep link, just open Safari
                        application.open(url)
                    }
                }

                return
            }
 
            self?.applicationFlowCoordinator.handleUniversalLink(linkItem)
        }
        
        Reteno.addInAppStatusHandler { inAppMessageStatus in
            switch inAppMessageStatus {
            case .inAppShouldBeDisplayed:
                print("inAppShouldBeDisplayed")
                
            case .inAppIsDisplayed:
                print("inAppIsDisplayed")
                
            case .inAppShouldBeClosed(let action):
                print("isButtonClicked:\(action.isButtonClicked)\nisCloseButtonClicked:\(action.isCloseButtonClicked)\nisOpenUrlClicked:\(action.isOpenUrlClicked)")
                
            case .inAppIsClosed(let action):
                print("isButtonClicked:\(action.isButtonClicked)\nisCloseButtonClicked:\(action.isCloseButtonClicked)\nisOpenUrlClicked:\(action.isOpenUrlClicked)")
                
            case .inAppReceivedError(let error):
                print("inAppReceivedError \(error)")
            }
        }
        
        let window = UIWindow()
        
        applicationFlowCoordinator = ApplicationFlowCoordinator(window: window)
        applicationFlowCoordinator.execute()
        
        self.window = window
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
        
        Reteno.userNotificationService.registerForRemoteNotifications()
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
    
    private func provideCustomDeviceId() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            Reteno.customDeviceIdProvider.setDeviceId(self?.customDeviceId ?? "")
        }
    }
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        print("Device token: ", fcmToken)
        Reteno.userNotificationService.processRemoteNotificationsToken(fcmToken)
    }
    
}

extension AppDelegate {
    
    var initializationTestDelayDuration: TimeInterval {
        10.0
    }
    
    // used for testing delayed initialization
    var isDelayedInitalizationForTest: Bool {
        userDefaults.bool(forKey: "isDelayedInitalization") 
    }
    
    var isCustomDeviceIdProviderEnabled: Bool {
        userDefaults.bool(forKey: "IsCustomDeviceId")
    }
    
    var customDeviceId: String? {
        userDefaults.string(forKey: "CustomDeviceId")
    }
    
    func set(isDelayedInitalizationForTest: Bool) {
        userDefaults.setValue(isDelayedInitalizationForTest, forKey: "isDelayedInitalization")
    }
    
    func completeDelayedInitialization() {
        let configuration: RetenoConfiguration = .init(isAutomaticScreenReportingEnabled: true, isAutomaticAppLifecycleReportingEnabled: true, isDebugMode: true)
        Reteno.delayedSetup(apiKey: apiKey, configuration: configuration)
    }
}
