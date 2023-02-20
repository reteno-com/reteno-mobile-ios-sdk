//
//  Reteno.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import Foundation
import UserNotifications

public struct Reteno {
    
    /// SDK version
    static var version = "1.5.3"
    /// Time interval in seconds between sending batches with events
    static var eventsSendingTimeInterval: TimeInterval = {
        DebugModeHelper.isDebugModeOn() ? 10 : 30
    }()
    
    @available(iOSApplicationExtension, unavailable)
    public static let userNotificationService = UserNotificationService.shared
        
    static let senderScheduler = EventsSenderSchedulerBuilder.build()
    static var analyticsService: AnalyticsService!
    
    private init() {}
    
    /// SDK initialization
    /// - Parameter apiKey: API key is used for authentication. You can create a key for a mobile application in the `Settings → Mobile Push` section in the `Reteno` cabinet.
    /// - Parameter isAutomaticScreenReportingEnabled: Flag that indicates if automatic screen view tracking enabled
    /// - Parameter isDebugMode: Flag that indicates if `DebugMode` is enabled
    public static func start(apiKey: String, isAutomaticScreenReportingEnabled: Bool = true, isDebugMode: Bool = false) {
        DeviceIdHelper.actualizeDeviceId()
        ApiKeyHelper.setApiKey(apiKey)
        DebugModeHelper.setIsDebugModeOn(isDebugMode)
        analyticsService = AnalyticsServiceBuilder.build(isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled)
        senderScheduler.subscribeOnNotifications()
    }
    
    /// Log events
    /// - Parameter eventTypeKey: Event type ID
    /// - Parameter date: Time when event occurred
    /// - Parameter parameters: List of event parameters as array of "key" - "value" pairs. Parameter keys are arbitrary. Used in campaigns and for dynamic content creation in messages.
    /// - Parameter forcePush: indicates if event should be send immediately or in the next scheduled batch.
    public static func logEvent(eventTypeKey: String, date: Date = Date(), parameters: [Event.Parameter], forcePush: Bool = false) {
        analyticsService.logEvent(eventTypeKey: eventTypeKey, date: date, parameters: parameters)
        if forcePush {
            senderScheduler.forcePushEvents()
        }
    }
    
    /// Update push notification status in `Reteno`
    /// - Parameter interactionId: `InteractionId` from push payload
    /// - Parameter status: Interaction status. Possible values `.delivered`, `.opened`, `.clicked`
    /// - Parameter date: Time when event occurred
    public static func updateNotificationInteractionStatus(interactionId: String, status: InteractionStatus, date: Date = Date()) {
        senderScheduler.updateNotificationInteractionStatus(interactionId: interactionId, status: status, date: date)
    }
    
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
        guard
            (externalUserId.isSome && externalUserId?.isEmpty == false)
                || userAttributes.isSome
                || subscriptionKeys.isNotEmpty
                || groupNamesInclude.isNotEmpty
                || groupNamesExclude.isNotEmpty
        else { return }
        
        if let externalUserId = externalUserId,
            !externalUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ExternalUserIdHelper.setId(externalUserId)
        }
        
        guard
            let userId = ExternalUserIdHelper.getId(),
            !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
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
        senderScheduler.updateUserAttributes(
            externalUserId: nil,
            userAttributes: UserAttributes(
                firstName: userAttributes.firstName,
                lastName: userAttributes.lastName,
                languageCode: userAttributes.languageCode,
                timeZone: userAttributes.timeZone,
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
    
}
