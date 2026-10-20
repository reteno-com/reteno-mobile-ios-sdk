//
//  Reteno.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UIKit
import Foundation
import UserNotifications

extension Reteno {
    
    // Notification should be posted by SDK on complete delayed initialization
    static let retenoDidBecomeActive: Notification.Name = .init(
        "com.reteno.didBecomeActive.after.delayed.initialization"
    )
    
    static let userUpdateInitiated: Notification.Name = .init(
        "com.reteno.userUpdateInitiated"
    )
    
    static let userUpdateCompleted: Notification.Name = .init(
        "com.reteno.userUpdateCompleted"
    )
}

public struct Reteno {
    
    @available(iOSApplicationExtension, unavailable)
    public static let userNotificationService: UserNotificationService = {
        let service = UserNotificationService.shared
        service.setScheduler(senderScheduler)
        return service
    }()
    public static let customDeviceIdProvider = CustomDeviceIdProvider()
    
    static let senderScheduler = EventsSenderSchedulerBuilder.build()
    static let sdkStateHelper = SDKStateHelper.shared

    /// SDK version
    static var version = "2.7.7"
    /// Time interval in seconds between sending batches with events
    static var eventsSendingTimeInterval: TimeInterval = {
        DebugModeHelper.isDebugModeOn() ? 10 : 30
    }()
    static var linkHandler: ((LinkHandler) -> Void)?
    static var inAppStatusHander: ((InAppMessageStatus) -> Void)?
    static var analyticsService: AnalyticsService!
    static var storage: KeyValueStorage!
    
    /// Separator between the base device id and the account suffix in a multi-account device id.
    static let accountSuffixSeparator = ":"
        
    private init() {}
    
    /// SDK initialization
    /// - Parameter apiKey: API key is used for authentication. You can create a key for a mobile application in the `Settings → Mobile Push` section in the `Reteno` cabinet.
    /// - Parameter deviceTokenHandlingMode: Defines how the SDK obtains the device push token. Use `.manual` if you use FCM or need to handle push token registration yourself by implementing: `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`. Use `.automatic` if you use APNs directly and do not need your own implementation of this method. In this mode, the SDK retrieves the device token automatically using method swizzling.
    /// - Parameter configuration: Defines SDK configuration
    @available(iOSApplicationExtension, unavailable)
    public static func start(apiKey: String,
                             deviceTokenHandlingMode: DeviceTokenHandlingMode,
                             configuration: RetenoConfiguration = RetenoConfiguration()) {
        guard !sdkStateHelper.isInitialized else {
            Logger.log("RetenoSDK was already initialized, skipping", eventType: .error)
            return
        }
        userNotificationService.setDeviceTokenHandlingMode(deviceTokenHandlingMode)
        let deviceIdProvider: DeviceIdProvider = configuration.useCustomDeviceId ? customDeviceIdProvider : DefaultDeviceIdProvider()
        deviceIdProvider.setDeviceIdCompletionHandler { deviceId in
            sdkStateHelper.set(isDelayedInitialization: false)
            sdkStateHelper.set(isInitialized: true)
            FileStorage.shared.configure()
            ApiKeyHelper.setApiKey(apiKey)
            DeviceIdHelper.actualizeDeviceId(providedDeviceId: deviceId)
            DebugModeHelper.setIsDebugModeOn(configuration.isDebugMode)
            storage = storage ?? StorageBuilder.build()
            let previousSessionConfiguration = storage.getStoredSessionConfiguration()
            storage.setAnalyticsValues(configuration: configuration)
            analyticsService = AnalyticsServiceBuilder.build(
                isAutomaticScreenReportingEnabled: configuration.isAutomaticScreenReportingEnabled,
                isAutomaticAppLifecycleReportingEnabled: configuration.isAutomaticAppLifecycleReportingEnabled,
                isApplicationForegroundLifecycleReportingEnabled: configuration.isApplicationForegroundLifecycleReportingEnabled
            )
            senderScheduler.subscribeOnNotifications()
            userNotificationService.setNotificationCenterDelegate()
            inApps.subscribeOnNotifications()
            inApps.updateSessionConfiguration(
                previous: previousSessionConfiguration,
                new: configuration.sessionConfiguration
            )
            pauseInAppMessages(isPaused: configuration.isPausedInAppMessages)
            setInAppMessagesPauseBehaviour(pauseBehaviour: configuration.inAppMessagesPauseBehaviour)
        }
    }
    
    /// SDK delayed initialization
    @available(iOSApplicationExtension, unavailable)
    public static func delayedStart() {
        sdkStateHelper.set(isDelayedInitialization: true)
        userNotificationService.setNotificationCenterDelegate()
    }
    
    /// SDK delayed  initialization (can be called only after Reteno.delayedStart(configuration:))
    /// - Parameter apiKey: API key is used for authentication. You can create a key for a mobile application in the `Settings → Mobile Push` section in the `Reteno` cabinet.
    /// - Parameter deviceTokenHandlingMode: Defines how the SDK obtains the device push token. Use `.manual` if you use FCM or need to handle push token registration yourself by implementing: `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`. Use `.automatic` if you use APNs directly and do not need your own implementation of this method. In this mode, the SDK retrieves the device token automatically using method swizzling.
    @available(iOSApplicationExtension, unavailable)
    public static func delayedSetup(apiKey: String,
                                    deviceTokenHandlingMode: DeviceTokenHandlingMode,
                                    configuration: RetenoConfiguration = RetenoConfiguration()) {
        guard !sdkStateHelper.isInitialized else {
            Logger.log("RetenoSDK was already initialized, skipping", eventType: .error)
            return
        }
        
        storage = storage ?? StorageBuilder.build()
        userNotificationService.setDeviceTokenHandlingMode(deviceTokenHandlingMode)

        guard sdkStateHelper.IsDelayedInitialization else {
            Logger.log("\(#function) can be called only after Reteno.delayedStart()", eventType: .error)
            return
        }
        
        let deviceIdProvider: DeviceIdProvider = configuration.useCustomDeviceId ? customDeviceIdProvider : DefaultDeviceIdProvider()
        
        deviceIdProvider.setDeviceIdCompletionHandler { deviceId in
            sdkStateHelper.set(isInitialized: true)
            FileStorage.shared.configure()
            ApiKeyHelper.setApiKey(apiKey)
            DeviceIdHelper.actualizeDeviceId(providedDeviceId : deviceId)
            DebugModeHelper.setIsDebugModeOn(configuration.isDebugMode)
            let previousSessionConfiguration = storage.getStoredSessionConfiguration()
            storage.setAnalyticsValues(configuration: configuration)
            analyticsService = AnalyticsServiceBuilder.build(
                isAutomaticScreenReportingEnabled: configuration.isAutomaticScreenReportingEnabled,
                isAutomaticAppLifecycleReportingEnabled: configuration.isAutomaticAppLifecycleReportingEnabled,
                isApplicationForegroundLifecycleReportingEnabled: configuration.isApplicationForegroundLifecycleReportingEnabled
            )
            senderScheduler.subscribeOnNotifications()
            inApps.subscribeOnNotifications()
            inApps.updateSessionConfiguration(
                previous: previousSessionConfiguration,
                new: configuration.sessionConfiguration
            )
            pauseInAppMessages(isPaused: configuration.isPausedInAppMessages)
            setInAppMessagesPauseBehaviour(pauseBehaviour: configuration.inAppMessagesPauseBehaviour)
            
            NotificationCenter.default.post(
                name: Reteno.retenoDidBecomeActive,
                object: UIApplication.shared
            )
            // fire collected push notification on finish delayed initialization
            if !sdkStateHelper.shouldCollectNotifications,
               let lastCollectedPushNotificationResponse = sdkStateHelper.popLastAndClearNotificationResponses() {
                userNotificationService.processRemoteNotificationResponse(lastCollectedPushNotificationResponse)
            }
        }
    }
    
    /// SDK initialization
    /// - Parameter apiKey: API key is used for authentication. You can create a key for a mobile application in the `Settings → Mobile Push` section in the `Reteno` cabinet.
    /// - Parameter deviceTokenHandlingMode: Defines how the SDK obtains the device push token. Use `.manual` if you use FCM or need to handle push token registration yourself by implementing: `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`. Use `.automatic` if you use APNs directly and do not need your own implementation of this method. In this mode, the SDK retrieves the device token automatically using method swizzling.
    /// - Parameter isAutomaticScreenReportingEnabled: Flag that indicates if automatic screen view tracking enabled
    /// - Parameter isDebugMode: Flag that indicates if `DebugMode` is enabled
    /// - Parameter isPausedInAppMessages: Flag that indicates pause in InAppMessage presenting
    @available(iOSApplicationExtension, unavailable)
    public static func start(
        apiKey: String,
        deviceTokenHandlingMode: DeviceTokenHandlingMode,
        isAutomaticScreenReportingEnabled: Bool = false,
        isDebugMode: Bool = false,
        isPausedInAppMessages: Bool = false,
        inAppMessagesPauseBehaviour: PauseBehaviour = .postponeInApps
    ) {
        let configuration: RetenoConfiguration = .init(
            isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled,
            isPausedInAppMessages: isPausedInAppMessages,
            inAppMessagesPauseBehaviour: inAppMessagesPauseBehaviour,
            isDebugMode: isDebugMode
        )
        start(apiKey: apiKey, deviceTokenHandlingMode: deviceTokenHandlingMode, configuration: configuration)
    }
    
    /// Log events
    /// - Parameter eventTypeKey: Event type ID
    /// - Parameter date: Time when event occurred
    /// - Parameter parameters: List of event parameters as array of "key" - "value" pairs. Parameter keys are arbitrary. Used in campaigns and for dynamic content creation in messages.
    /// - Parameter forcePush: indicates if event should be send immediately or in the next scheduled batch.
    public static func logEvent(eventTypeKey: String, date: Date = Date(), parameters: [Event.Parameter], forcePush: Bool = false) {
        if analyticsService.isNone {
            /// Check and initialize `AnalyticsService`. It might be `nil` if is being called from app extension.
            storage = storage ?? StorageBuilder.build()
            let isAutomaticScreenReportingEnabled: Bool = storage.getValue(forKey: StorageKeys.screenTrackingFlag.rawValue)
            let isAutomaticAppLifecycleReportingEnabled: Bool = storage.getValue(forKey: StorageKeys.automaticAppLifecycleReportingEnabled.rawValue)
            let isApplicationForegroundLifecycleReportingEnabled: Bool = storage.getValue(forKey: StorageKeys.applicationForegroundLifecycleReportingEnabled.rawValue)
            analyticsService = AnalyticsService(
                isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled,
                isAutomaticAppLifecycleReportingEnabled: isAutomaticAppLifecycleReportingEnabled,
                isApplicationForegroundLifecycleReportingEnabled: isApplicationForegroundLifecycleReportingEnabled,
                storage: storage
            )
        }
        analyticsService.logEvent(eventTypeKey: eventTypeKey, date: date, parameters: parameters)
        inApps.logEventTrigger(eventTypeKey: eventTypeKey, parameters: parameters)
        if forcePush {
            senderScheduler.forcePushEvents()
        }
    }
    
    /// Log events
    /// - Parameter eventTypeKey: Event type ID
    /// - Parameter date: Time when event occurred
    /// - Parameter jsonParameters: JSON Dictionary of event parameters of "key" - "value" pairs. Parameter keys are arbitrary. Used in campaigns and for dynamic content creation in messages.
    /// - Parameter forcePush: indicates if event should be send immediately or in the next scheduled batch.
    public static func logEvent(eventTypeKey: String, date: Date = Date(), jsonParameters: [String: String], forcePush: Bool = false) {
        let params = jsonParameters.map({ Event.Parameter(name: $0.key, value: $0.value) })
        logEvent(eventTypeKey: eventTypeKey, date: date, parameters: params, forcePush: forcePush)
    }
    
    public static func addLinkHandler(_ handler: @escaping (LinkHandler) -> Void) {
        linkHandler = handler
    }
    
    public static func addInAppStatusHandler(_ handler: @escaping (InAppMessageStatus) -> Void) {
        inAppStatusHander = handler
    }
    
    /// Update push notification status in `Reteno`
    /// - Parameter interactionId: `InteractionId` from push payload
    /// - Parameter status: Interaction status. Possible values `.delivered`, `.opened`, `.clicked`
    /// - Parameter date: Time when event occurred
    public static func updateNotificationInteractionStatus(interactionId: String, status: InteractionStatus, date: Date = Date()) {
        senderScheduler.updateNotificationInteractionStatus(interactionId: interactionId, status: status, date: date)
    }
    
    @available(iOSApplicationExtension, unavailable)
    /// Update MultiAccount User attributes
    ///
    /// Every account gets its own device id: `<baseDeviceId>:<accountSuffix>`. The suffix defaults to
    /// `externalUserId`. When neither `accountSuffix` nor `externalUserId` is provided the device id is
    /// reset to the base one. Switching accounts drops the previous account's identity (external user id,
    /// email, phone and the cached device/user snapshots) before the new device id is registered, so nothing
    /// of the previous account is ever attached to the new device id. Data the previous account queued but has
    /// not sent yet (events, user updates, etc.) is still sent with the previous device id and external user id.
    /// - Parameter externalUserId: Id for identify user in a system (optional)
    /// - Parameter userAttributes: user specific attributes in format `UserAttributes` (firstName, phone, email, etc.) (optional)
    /// - Parameter subscriptionKeys: list of subscription categories keys, can be empty
    /// - Parameter groupNamesInclude: list of group ID to add a contact to, can be empty
    /// - Parameter groupNamesExclude: list of group ID to remove a contact from, can be empty
    /// - Parameter accountSuffix: account suffix which will be appended to the base device id via `:`. Defaults to `externalUserId`
    public static func updateMultiAccountUserAttributes(
        externalUserId: String? = nil,
        userAttributes: UserAttributes? = nil,
        subscriptionKeys: [String] = [],
        groupNamesInclude: [String] = [],
        groupNamesExclude: [String] = [],
        accountSuffix: String? = nil
    ) {
        guard sdkStateHelper.isInitialized else {
            Logger.log(
                "\(#function) could be called only after complete initialization Reteno, finish it.",
                eventType: .error
            )
            return
        }
        
        if let currentDeviceId = DeviceIdHelper.deviceId() {
            let baseDeviceId = DeviceIdHelper.baseDeviceID() ?? currentDeviceId
            let suffix = normalizedAccountSuffix(accountSuffix) ?? normalizedAccountSuffix(externalUserId)
            let newDeviceId = suffix.map { baseDeviceId + accountSuffixSeparator + $0 } ?? baseDeviceId
            
            if DeviceIdHelper.baseDeviceID() == nil {
                DeviceIdHelper.saveBaseDeviceId(baseDeviceId)
            }
            if newDeviceId != currentDeviceId {
                switchAccount(
                    toDeviceId: newDeviceId,
                    baseDeviceId: baseDeviceId,
                    externalUserId: externalUserId,
                    userAttributes: userAttributes
                )
            }
        }
        updateUserAttributes(
            externalUserId: externalUserId,
            userAttributes: userAttributes,
            subscriptionKeys: subscriptionKeys,
            groupNamesInclude: groupNamesInclude,
            groupNamesExclude: groupNamesExclude
        )
    }
    
    @available(iOSApplicationExtension, unavailable)
    /// Update User attributes
    /// - Parameter externalUserId: Id for identify user in a system (optional)
    /// - Parameter userAttributes: user specific attributes in format `UserAttributes` (firstName, phone, email, etc.) (optional)
    /// - Parameter subscriptionKeys: list of subscription categories keys, can be empty
    /// - Parameter groupNamesInclude: list of group ID to add a contact to, can be empty
    /// - Parameter groupNamesExclude: list of group ID to remove a contact from, can be empty
    public static func updateUserAttributes(
        externalUserId: String? = nil,
        userAttributes: UserAttributes? = nil,
        subscriptionKeys: [String] = [],
        groupNamesInclude: [String] = [],
        groupNamesExclude: [String] = []
    ) {
        guard sdkStateHelper.isInitialized else {
            Logger.log(
                "\(#function) could be called only after complete initialization Reteno, finish it.",
                eventType: .error
            )
            return
        }
        
        guard
            (externalUserId.isSome && externalUserId?.isEmpty == false)
                || userAttributes.isSome
                || subscriptionKeys.isNotEmpty
                || groupNamesInclude.isNotEmpty
                || groupNamesExclude.isNotEmpty
        else { return }
        
        if let externalUserId = externalUserId,
            !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            NotificationCenter.default.post(name: Reteno.userUpdateInitiated, object: nil)
            
            ExternalUserIdHelper.setId(externalUserId)
        }
        
        if let email = userAttributes?.email,
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ExternalUserDataHelper.setEmail(email)
        }
        
        if let phone = userAttributes?.phone,
            !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ExternalUserDataHelper.setPhone(phone)
        }
        
        guard
            let userId = ExternalUserIdHelper.getId(),
            !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
            Logger.log("Trying to update user with empty ID. This operation won't be completed.", eventType: .error)
            return
        }
        
        senderScheduler.updateUserAttributes(
            externalUserId: externalUserId,
            userAttributes: userAttributes,
            subscriptionKeys: subscriptionKeys,
            groupNamesInclude: groupNamesInclude,
            groupNamesExclude: groupNamesExclude,
            isAnonymous: false
        )
    }
    
    /// Update Anonymous User attributes
    /// - Parameter userAttributes: user specific attributes in format `AnonymousUserAttributes` (firstName, address, etc.)
    /// - Parameter subscriptionKeys: list of subscription categories keys, can be empty
    /// - Parameter groupNamesInclude: list of group ID to add a contact to, can be empty
    /// - Parameter groupNamesExclude: list of group ID to remove a contact from, can be empty
    public static func updateAnonymousUserAttributes(
        userAttributes: AnonymousUserAttributes,
        subscriptionKeys: [String] = [],
        groupNamesInclude: [String] = [],
        groupNamesExclude: [String] = []
    ) {
        guard sdkStateHelper.isInitialized else {
            Logger.log(
                "\(#function) could be called only after complete initialization Reteno, finish it.",
                eventType: .error
            )
            return
        }
        
        senderScheduler.updateUserAttributes(
            externalUserId: nil,
            userAttributes: UserAttributes(
                firstName: userAttributes.firstName,
                lastName: userAttributes.lastName,
                languageCode: userAttributes.languageCode,
                timeZone: userAttributes.timeZone,
                marketId: userAttributes.marketId,
                address: userAttributes.address,
                fields: userAttributes.fields
            ),
            subscriptionKeys: subscriptionKeys,
            groupNamesInclude: groupNamesInclude,
            groupNamesExclude: groupNamesExclude,
            isAnonymous: true
        )
    }
    
    // MARK: App Inbox
    
    private static var appInbox: AppInbox = {
        AppInbox(
            requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(),
            storage: StorageBuilder.build()
        )
    }()
    
    /// Get instance of `AppInbox`
    public static func inbox() -> AppInbox { appInbox }
    
    // MARK: Recommendations
    
    private static var recoms: Recommendations = {
        Recommendations(
            requestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(),
            storage: StorageBuilder.build()
        )
    }()
    
    /// Get instance of `Recommendations`
    public static func recommendations() -> Recommendations { recoms }
    
    // MARK: Ecommerce
    
    private static var ecom: Ecommerce = {
        Ecommerce(requestService: MobileRequestServiceBuilder.build(), storage: StorageBuilder.build())
    }()
    
    public static func ecommerce() -> Ecommerce { ecom }
    
    // MARK: InApp messages
    
    private static var inApps: InAppMessages = {
        InAppMessages(
            mobileRequestService: MobileRequestServiceBuilder.buildWithDeviceIdInHeaders(),
            inAppRequestService: InAppRequestService(requestManager: NetworkBuilder.buildApiManagerWithEmptyBaseURL()),
            storage: StorageBuilder.build(), 
            sessionService: SessionService()
        )
    }()
    
    /// Account suffix of the current multi-account device id (the part after `<baseDeviceId>:`), `nil` when the base device id is in use.
    public static func accountSuffix() -> String? {
        guard let currentDeviceId = DeviceIdHelper.deviceId(),
              let baseDeviceId = DeviceIdHelper.baseDeviceID(),
              currentDeviceId.hasPrefix(baseDeviceId + accountSuffixSeparator) else { return nil }
        
        return normalizedAccountSuffix(String(currentDeviceId.dropFirst(baseDeviceId.count + accountSuffixSeparator.count)))
    }
    
    static func inAppMessages() -> InAppMessages { inApps }
        
    @available(iOSApplicationExtension, unavailable)
    public static func pauseInAppMessages(isPaused: Bool) {
        guard sdkStateHelper.isInitialized else {
            Logger.log(
                "\(#function) could be called only after complete initialization Reteno, finish it.",
                eventType: .error
            )
            return
        }
        
        inApps.setInAppMessagesPause(isPaused: isPaused)
    }
    
    public static func setInAppMessagesPauseBehaviour(pauseBehaviour: PauseBehaviour) {
        inApps.setInAppMessagesPauseBehaviour(pauseBehaviour: pauseBehaviour)
    }
    
    // MARK: Upsert device
    
    static func upsertDevice(_ device: Device) {
        guard sdkStateHelper.isInitialized else {
            Logger.log(
                "\(#function) could be called only after complete initialization Reteno, finish it.",
                eventType: .error
            )
            return
        }
        
        senderScheduler.upsertDevice(device)
    }
    
    // MARK: - Mark notification as delivered
    
    static func markNotificationAsDelivered(interactionId: String, date: Date = Date()) {
        senderScheduler.forceUpdateNotificationInteractionStatus(interactionId: interactionId, status: .delivered, date: date)
    }
    
    // MARK: - Multi-account
    
    /// Trims the suffix and strips leading separators, so a caller that passes `":123"` (the format required
    /// before the separator was inserted by the SDK) ends up with the same device id as one passing `"123"`.
    /// Returns `nil` for an empty suffix.
    private static func normalizedAccountSuffix(_ suffix: String?) -> String? {
        guard var suffix = suffix?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        
        while suffix.hasPrefix(accountSuffixSeparator) {
            suffix.removeFirst(accountSuffixSeparator.count)
        }
        
        return suffix.isEmpty ? nil : suffix
    }
    
    /// Switches the SDK to another account's device id.
    ///
    /// Order matters here. The previous account's identity is cleared and the new one is written to storage
    /// *before* the device is registered under the new id, otherwise `v1/device` for the new id is sent with
    /// the previous account's external user id / email / phone and the server links both accounts together.
    /// Data the previous account queued before the switch captured its `RequestIdentity` and is still sent
    /// with the previous device id, so it does not have to be flushed first.
    @available(iOSApplicationExtension, unavailable)
    private static func switchAccount(
        toDeviceId newDeviceId: String,
        baseDeviceId: String,
        externalUserId: String?,
        userAttributes: UserAttributes?
    ) {
        // Close the previous account's session and in-app state while its identity is still in place.
        inApps.endSession()
        inApps.clearInApps()
        
        // Drop everything that identifies the previous account.
        let keyValueStorage = StorageBuilder.build()
        ExternalUserIdHelper.clear()
        ExternalUserDataHelper.clear()
        keyValueStorage.clearCachedUser()
        keyValueStorage.clearCachedDevice()
        
        DeviceIdHelper.saveBaseDeviceId(baseDeviceId)
        DeviceIdHelper.saveDeviceId(newDeviceId)
        
        // Write the new identity so the device upsert below carries it.
        if let externalUserId = externalUserId?.trimmingCharacters(in: .whitespacesAndNewlines), !externalUserId.isEmpty {
            ExternalUserIdHelper.setId(externalUserId)
        }
        if let email = userAttributes?.email?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            ExternalUserDataHelper.setEmail(email)
        }
        if let phone = userAttributes?.phone?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty {
            ExternalUserDataHelper.setPhone(phone)
        }
        
        // The new device id is not confirmed by the backend yet; the scheduler keeps re-registering it until it is.
        keyValueStorage.set(value: false, forKey: StorageKeys.isUpdatedDevice.rawValue)
        DeviceIdHelper.upsertCurrentDevice()
        inApps.startSession()
    }
}
