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
    private var applicationFlowCoordinator: ApplicationFlowCoordinator?
    
    private var isRunningTests: Bool {
      NSClassFromString("XCTestCase") != nil
    }
    
    var apiKey: String = "SDK_API_KEY"
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        if isRunningTests {
          return true
        }
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        registerSessionConfigDefaults()
        
        if isDelayedInitalizationForTest {
            Reteno.delayedStart()
        } else {
            let configuration: RetenoConfiguration = .init(isAutomaticScreenReportingEnabled: true,
                                                           isAutomaticAppLifecycleReportingEnabled: true,
                                                           isApplicationForegroundLifecycleReportingEnabled: applicationForegroundLifecycleReportingEnabled(),
                                                           sessionConfiguration: sessionConfiguration(),
                                                           isDebugMode: true,
                                                           useCustomDeviceId: isCustomDeviceIdProviderEnabled)
            Reteno.start(apiKey: apiKey,
                         deviceTokenHandlingMode: .manual,
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
 
            self?.applicationFlowCoordinator?.handleUniversalLink(linkItem)
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
        
        observeScheduledCustomEvents()
        CustomEventScheduler.shared.start()
        
        return true
    }
    
    private func observeScheduledCustomEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scheduledCustomEventDidFire),
            name: CustomEventScheduler.didFireEventNotification,
            object: nil
        )
    }
    
    @objc
    private func scheduledCustomEventDidFire(_ notification: Notification) {
        guard
            let eventName = notification.userInfo?[CustomEventScheduler.firedEventNameUserInfoKey] as? String
        else { return }
        
        let alert = InformationAlert(
            text: String(format: NSLocalizedString("custom_event_screen.fired_alert.message", comment: ""), eventName),
            backgroundType: .scheduledEvent
        )
        window?.showInformationAlert(alert)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func configureMainWindow(_ window: UIWindow) {
        self.window = window
        
        if isRunningTests {
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            return
        }
        
        let coordinator = ApplicationFlowCoordinator(window: window)
        applicationFlowCoordinator = coordinator
        coordinator.execute()
    }
    
    func handleOpenURL(_ url: URL) {
        applicationFlowCoordinator?.handleDeeplink(url)
    }
    
    @discardableResult
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard
            userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let linkItem = UniversalLinkItem(rawValue: components.path)
        else { return false }
        
        applicationFlowCoordinator?.handleUniversalLink(linkItem)
        
        return false
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
        let configuration: RetenoConfiguration = .init(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: applicationForegroundLifecycleReportingEnabled(),
            sessionConfiguration: sessionConfiguration(),
            isDebugMode: true
        )
        Reteno.delayedSetup(apiKey: apiKey, deviceTokenHandlingMode: .manual, configuration: configuration)
    }
    
    // MARK: - Session configuration
    
    private func registerSessionConfigDefaults() {
        userDefaults.register(defaults: [
            SessionConfigUserDefaultsKey.sessionDuration: RetenoSessionConfiguration.default.sessionDuration,
            SessionConfigUserDefaultsKey.isSessionStartReportingEnabled: RetenoSessionConfiguration.default.isSessionStartReportingEnabled,
            SessionConfigUserDefaultsKey.isSessionEndReportingEnabled: RetenoSessionConfiguration.default.isSessionEndReportingEnabled,
            SessionConfigUserDefaultsKey.isApplicationForegroundLifecycleReportingEnabled: false
        ])
    }
    
    private func sessionConfiguration() -> RetenoSessionConfiguration {
        RetenoSessionConfiguration(
            sessionDuration: userDefaults.double(forKey: SessionConfigUserDefaultsKey.sessionDuration),
            isSessionStartReportingEnabled: userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isSessionStartReportingEnabled),
            isSessionEndReportingEnabled: userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isSessionEndReportingEnabled)
        )
    }
    
    private func applicationForegroundLifecycleReportingEnabled() -> Bool {
        userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isApplicationForegroundLifecycleReportingEnabled)
    }
}
