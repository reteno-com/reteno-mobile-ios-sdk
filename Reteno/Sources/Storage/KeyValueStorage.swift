//
//  KeyValueStorage.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 21.09.2022.
//

import Foundation

enum StorageKeys: String, CaseIterable {
    
    case pushToken = "com.reteno.push-token.key"
    case isPushSubscribed = "com.reteno.is-push-subscribed.key"
    case isUpdatedDevice = "com.reteno.is-updated-device.key"
    case cachedDevice = "com.reteno.last-sended-device.key"
    case deviceId = "com.reteno.device-id.key"
    case externalUserId = "com.reteno.external-user-id.key"
    case emailId = "com.reteno.email-id.key"
    case phoneId = "com.reteno.phone-id.key"
    case apiKey = "com.reteno.api-key.key"
    case events = "com.reteno.events.key"
    case notificationStatuses = "com.reteno.notification-statuses.key"
    case users = "com.reteno.users.key"
    case cachedUser = "com.reteno.last-sended-user.key"
    case debugModeFlag = "com.reteno.debug-mode-flag.key"
    case recomEvents = "com.reteno.recom_events.key"
    case inboxOpenedMessagesIds = "com.reteno.inbox_opened_messages_ids.key"
    case wrappedLinks = "com.reteno.wrapped-links.key"
    case screenTrackingFlag = "com.reteno.screen-tracking-flag.key"
    case inAppMessageBaseHTMLVersion = "com.reteno.in-app_message_base_html.key"
    case errorEvents = "com.reteno.error_events.key"
    case devicePlatform = "com.reteno.device_platform.key"
    case inAppMessagePauseFlag = "com.reteno.in-app-message-pause-flag.key"
    case lastActivityDate = "com.reteno.last-activity-date.key"
    case sessionDuration = "com.reteno.start-session-date.key"
    case noLimitInApps = "com.reteno.no-limit-in-apps.key"
    case onlyOnceInApps = "com.reteno.only-once-in-apps.key"
    case oncePerSessionInApps = "com.reteno.once-per-session-in-apps.key"
    case minIntervalValue = "com.reteno.min-interval-value.key"
    case timePerUnitInApps = "com.reteno.time-per-unit-in-apps.key"
    case eTag = "com.reteno.e-tag.key"
    case inAppMessages = "com.reteno.in-app-messages.key"
    case inAppMessageContents = "com.reteno.in-app-message-contents.key"
    case inAppCacheLastUpdate = "com.reteno.in-app-cache-last-update.key"
    case sessionId = "com.reteno.session-id.key"
    case applicationOpenedCount = "com.reteno.application-opened-count.key"
    case applicationBackgroundedCount = "com.reteno.application-backgrounded-count.key"
    case previousVersion = "com.reteno.previous-version.key"
    case previousBuild = "com.reteno.previous-build.key"
    case automaticAppLifecycleReportingEnabled = "com.reteno.automatic-app-lifecycle-reporting.key"
    case automaticPushSubsriptionReportingEnabled = "com.reteno.automatic-push-subsription-reporting.key"
    case automaticSessionReportingEnabled = "com.reteno.automatic-session-reporting.key"
    case retenoConfiguration = "com.reteno.reteno-configuration.key"
    case isDelayedInitialization = "com.reteno.reteno-delayed-initialization.key"
}

final class KeyValueStorage {
    
    private let storage: UserDefaults?
    
    init(storage: UserDefaults? = UserDefaults(suiteName: "group.\(BundleIdHelper.getMainAppBundleId()).reteno-local-storage")) {
        self.storage = storage
    }
    
    func set(value: String, forKey key: String) {
        guard let storage = storageUnwrapper() else { return }
        
        storage.setValue(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> String? {
        guard let storage = storageUnwrapper() else { return nil }
        
        return storage.string(forKey: key)
    }
    
    func set(value: Bool, forKey key: String) {
        guard let storage = storageUnwrapper() else { return }
        
        storage.setValue(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Bool {
        guard let storage = storageUnwrapper() else { return false }
        
        return storage.bool(forKey: key)
    }
    
    func set(value: Double, forKey key: String) {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Double? {
        guard let storage = storageUnwrapper() else { return nil }

        return storage.double(forKey: key)
    }
    
    func set(value: Int, forKey key: String) {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Int? {
        guard let storage = storageUnwrapper() else { return nil }

        return storage.integer(forKey: key)
    }
    
    func removeValue(forKey key: String) {
        guard let storage = storageUnwrapper() else { return }
        
        storage.removeObject(forKey: key)
    }
    
    // MARK: Analytics logic

    func setAnalyticsValues(configuration: RetenoConfiguration) {
        guard let storage = storageUnwrapper() else { return }

        storage.setValue(
            configuration.isAutomaticScreenReportingEnabled,
            forKey: StorageKeys.screenTrackingFlag.rawValue
        )
        storage.setValue(
            configuration.isAutomaticAppLifecycleReportingEnabled,
            forKey: StorageKeys.automaticAppLifecycleReportingEnabled.rawValue
        )
        storage.setValue(
            configuration.isAutomaticPushSubsriptionReportingEnabled,
            forKey: StorageKeys.automaticPushSubsriptionReportingEnabled.rawValue
        )
        storage.setValue(
            configuration.isAutomaticSessionReportingEnabled,
            forKey: StorageKeys.automaticSessionReportingEnabled.rawValue
        )
    }
    
    // MARK: - Delayed initialization
    
    func set(isDelayedInitialization: Bool) {
        guard let storage = storageUnwrapper() else { return }

        storage.setValue(
            isDelayedInitialization,
            forKey: StorageKeys.isDelayedInitialization.rawValue
        )
    }
    
    func getIsDelayedInitialization() -> Bool {
        guard let storage = storageUnwrapper() else { return false }

        return storage.bool(forKey: StorageKeys.isDelayedInitialization.rawValue)
    }
    
    // MARK: Events logic
    
    func addEvent(_ event: Event) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingEvents = getEvents()
            existingEvents.append(event)
            let encodedEvents = try JSONEncoder().encode(existingEvents)
            storage.set(encodedEvents, forKey: StorageKeys.events.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getEvents() -> [Event] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.events.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
            
            return decodedEvents
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func clearEventsCache() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.events.rawValue)
    }
    
    func clearEvents(_ events: [Event]) {
        guard let storage = storageUnwrapper() else { return }
        
        let idForRemove = events.map { $0.id }
        let resultEvents = getEvents().filter { !idForRemove.contains($0.id) }
        
        do {
            let encodedEvents = try JSONEncoder().encode(resultEvents)
            storage.set(encodedEvents, forKey: StorageKeys.events.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: NotificationStatus logic
    
    func addNotificationStatus(_ model: NotificationStatus) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingStatuses = getNotificationStatuses()
            existingStatuses.append(model)
            let encodedStatuses = try JSONEncoder().encode(existingStatuses)
            storage.set(encodedStatuses, forKey: StorageKeys.notificationStatuses.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getNotificationStatuses() -> [NotificationStatus] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.notificationStatuses.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([NotificationStatus].self, from: data)
            
            return decodedEvents
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func clearNotificationStatus(_ model: NotificationStatus) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingStatuses = getNotificationStatuses()
            existingStatuses.removeAll(where: { $0.id == model.id })
            let encodedStatuses = try JSONEncoder().encode(existingStatuses)
            storage.set(encodedStatuses, forKey: StorageKeys.notificationStatuses.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func clearOldNotificationStatusesCache() {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingStatuses = getNotificationStatuses()
            existingStatuses.removeAll(where: { !$0.isValid })
            let encodedStatuses = try JSONEncoder().encode(existingStatuses)
            storage.set(encodedStatuses, forKey: StorageKeys.notificationStatuses.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: Users logic
    
    func addUser(_ user: User) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingUsers = getUsers()
            existingUsers.append(user)
            let encodedUsers = try JSONEncoder().encode(existingUsers)
            storage.set(encodedUsers, forKey: StorageKeys.users.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getUsers() -> [User] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.users.rawValue) else { return [] }
            
            let decodedUsers = try JSONDecoder().decode([User].self, from: data)
            
            return decodedUsers
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func clearUser(_ user: User) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingUsers = getUsers()
            existingUsers.removeAll(where: { $0.id == user.id })
            let encodedUsers = try JSONEncoder().encode(existingUsers)
            storage.set(encodedUsers, forKey: StorageKeys.users.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    private func storageUnwrapper() -> UserDefaults? {
        guard let storage = storage else {
            ErrorLogger.shared.capture(error: StorageDoesNotExistError())
            
            return nil
        }
        
        return storage
    }
    
    func updateCachedUser(_ user: User?) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            let encodedUser = try JSONEncoder().encode(user)
            storage.set(encodedUser, forKey: StorageKeys.cachedUser.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getCachedUser() -> User? {
        guard let storage = storageUnwrapper() else { return nil }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.cachedUser.rawValue) else { return nil }
            
            let decodedUser = try JSONDecoder().decode(User.self, from: data)
            
            return decodedUser
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return nil
        }
    }
    
    func clearCachedUser() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set(nil, forKey: StorageKeys.cachedUser.rawValue)
    }
    
    // MARK: Cached Device Request
    
    func updateCachedDevice(_ cachedDevice: [String: Any]) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            let cachedDevice = try JSONSerialization.data(withJSONObject: cachedDevice, options: .prettyPrinted)
            storage.set(cachedDevice, forKey: StorageKeys.cachedDevice.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getCachedDevice() -> [String: Any]? {
        guard let storage = storageUnwrapper() else { return nil }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.cachedDevice.rawValue) else { return nil }
            
            let decodedDevice = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            return decodedDevice
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return nil
        }
    }
    
    func clearCachedDevice() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set(nil, forKey: StorageKeys.cachedDevice.rawValue)
    }
    
    // MARK: Recom events logic
    
    func addRecomEvent(_ event: RecomEvents) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingEvents = getRecomEvents()
            existingEvents.append(event)
            let encodedEvents = try JSONEncoder().encode(existingEvents)
            storage.set(encodedEvents, forKey: StorageKeys.recomEvents.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getRecomEvents() -> [RecomEvents] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.recomEvents.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([RecomEvents].self, from: data)
            
            return decodedEvents
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func clearRecomEventsCache() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.recomEvents.rawValue)
    }
    
    func clearRecomEvents(_ events: [RecomEvents]) {
        guard let storage = storageUnwrapper() else { return }
        
        let idForRemove = events.map { $0.id }
        let resultEvents = getRecomEvents().filter { !idForRemove.contains($0.id) }
        
        do {
            let encodedEvents = try JSONEncoder().encode(resultEvents)
            storage.set(encodedEvents, forKey: StorageKeys.recomEvents.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: App inbox messages ids logic
    
    func addInboxOpenedMessagesIds(_ ids: [AppInboxMessageStorableId]) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingIds = getInboxOpenedMessagesIds()
            let idsToAdd = ids.filter { item in
                !existingIds.contains {  $0.id == item.id }
            }
            existingIds.append(contentsOf: idsToAdd)
            let encodedIds = try JSONEncoder().encode(existingIds)
            storage.set(encodedIds, forKey: StorageKeys.inboxOpenedMessagesIds.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }

    func getInboxOpenedMessagesIds() -> [AppInboxMessageStorableId] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.inboxOpenedMessagesIds.rawValue) else { return [] }
            
            let decodedIds = try JSONDecoder().decode([AppInboxMessageStorableId].self, from: data)
            
            return decodedIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }

    func clearInboxOpenedMessagesIds(_ ids: [AppInboxMessageStorableId]) {
        guard let storage = storageUnwrapper() else { return }
        
        let idForRemove = ids.map { $0.id }
        let resultIds = getInboxOpenedMessagesIds().filter { !idForRemove.contains($0.id) }
        
        do {
            let encodedIds = try JSONEncoder().encode(resultIds)
            storage.set(encodedIds, forKey: StorageKeys.inboxOpenedMessagesIds.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }

    func clearInboxOpenedMessagesIdsCache() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.inboxOpenedMessagesIds.rawValue)
    }
    
    // MARK: Wrapped links logic
    
    func appendLink(_ link: StorableLink) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingLinks = getLinks()
            existingLinks.append(link)
            let encodedLinks = try JSONEncoder().encode(existingLinks)
            storage.set(encodedLinks, forKey: StorageKeys.wrappedLinks.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func getLinks() -> [StorableLink] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.wrappedLinks.rawValue) else { return [] }
            
            let decodedLinks = try JSONDecoder().decode([StorableLink].self, from: data)
            return decodedLinks
        } catch {
            ErrorLogger.shared.capture(error: error)
            return []
        }
    }
    
    func clearLinks(_ links: [StorableLink]) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingLinks = getLinks()
            existingLinks.removeAll(where: { links.contains($0) })
            let encodedLinks = try JSONEncoder().encode(existingLinks)
            storage.set(encodedLinks, forKey: StorageKeys.wrappedLinks.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func clearAllLinks() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.setValue([], forKey: StorageKeys.wrappedLinks.rawValue)
    }
    
    // MARK: Error
    
    func addErrorEvent(_ event: ErrorEvent) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingEvents = getErrorEvents()
            existingEvents.append(event)
            let encodedEvents = try JSONEncoder().encode(existingEvents)
            storage.set(encodedEvents, forKey: StorageKeys.errorEvents.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }

    
    func getErrorEvents() -> [ErrorEvent] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.errorEvents.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([ErrorEvent].self, from: data)
            
            return decodedEvents
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func clearErrorEvents(_ errorEvents: [ErrorEvent]) {
        guard let storage = storageUnwrapper() else { return }
        
        let idForRemove = errorEvents.map { $0.id }
        let resultEvents = getErrorEvents().filter { !idForRemove.contains($0.id) }
        
        do {
            let encodedEvents = try JSONEncoder().encode(resultEvents)
            storage.set(encodedEvents, forKey: StorageKeys.errorEvents.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func clearAllErrorEvents() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.errorEvents.rawValue)
    }
    
    // MARK: Only once - Displayed inApp ids
    
    func getOnlyOnceDisplayedInAppIds() -> [Int] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.onlyOnceInApps.rawValue) else { return [] }
            
            let decodedInAppsIds = try JSONDecoder().decode([Int].self, from: data)
            return decodedInAppsIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func addOnlyOnceDisplayedId(id: Int) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingIds = getOnlyOnceDisplayedInAppIds()
            existingIds.append(id)
            let encodedIds = try JSONEncoder().encode(existingIds)
            storage.set(encodedIds, forKey: StorageKeys.onlyOnceInApps.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: No Limit - Displayed inApp ids
    
    func getNoLimitDisplayedInAppIds() -> [Int] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.noLimitInApps.rawValue) else { return [] }
            
            let decodedInAppsIds = try JSONDecoder().decode([Int].self, from: data)
            return decodedInAppsIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func addNoLimitDisplayedId(id: Int) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingIds = getNoLimitDisplayedInAppIds()
            existingIds.append(id)
            let encodedIds = try JSONEncoder().encode(existingIds)
            storage.set(encodedIds, forKey: StorageKeys.noLimitInApps.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func clearNoLimitEvents() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.noLimitInApps.rawValue)
    }
    
    // MARK: Once per session - Displayed inApp ids
    
    func getOncePerSessionDisplayedInAppIds() -> [Int] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.oncePerSessionInApps.rawValue) else { return [] }
            
            let decodedInAppsIds = try JSONDecoder().decode([Int].self, from: data)
            return decodedInAppsIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return []
        }
    }
    
    func addOncePerSessionDisplayedId(id: Int) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingIds = getOncePerSessionDisplayedInAppIds()
            existingIds.append(id)
            let encodedIds = try JSONEncoder().encode(existingIds)
            storage.set(encodedIds, forKey: StorageKeys.oncePerSessionInApps.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    func clearOncePerSessionEvents() {
        guard let storage = storageUnwrapper() else { return }
        
        storage.set([], forKey: StorageKeys.oncePerSessionInApps.rawValue)
    }
    
    // MARK: Min Interval - Displayed inApp Id and Date
    
    func getMinIntervalInApps() -> [Int: Date] {
        guard let storage = storageUnwrapper() else { return [:] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.minIntervalValue.rawValue) else { return [:] }
            
            let decodedInAppsIds = try JSONDecoder().decode([Int: Date].self, from: data)
            return decodedInAppsIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return [:]
        }
    }
    
    func addMinIntervalInApps(id: Int) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            var existingIds = getMinIntervalInApps()
            existingIds[id] = Date()
            let encodedIds = try JSONEncoder().encode(existingIds)
            storage.set(encodedIds, forKey: StorageKeys.minIntervalValue.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: Time Per Time Unit
    
    func getTimePerTimeUnitInApps() -> [Int: [Date]] {
        guard let storage = storageUnwrapper() else { return [:] }

        do {
            guard let data = storage.data(forKey: StorageKeys.timePerUnitInApps.rawValue) else { return [:] }
            
            let decodedInAppsIds = try JSONDecoder().decode([Int: [Date]].self, from: data)
            return decodedInAppsIds
        } catch {
            ErrorLogger.shared.capture(error: error)
            
            return [:]
        }
    }
    
    func addTimePerTimeUnitInApps(id: Int) {
        guard let storage = storageUnwrapper() else { return }

        do {
            var existingInApps = getTimePerTimeUnitInApps()
            var existingInAppsTime: [Date] = existingInApps[id] ?? []
            existingInAppsTime.append(Date())
            existingInApps[id] = existingInAppsTime
            let encodedIds = try JSONEncoder().encode(existingInApps)
            storage.set(encodedIds, forKey: StorageKeys.timePerUnitInApps.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
    
    // MARK: In App Messages
    
    func getInAppMessages() -> [Message] {
        guard let storage = storageUnwrapper() else { return [] }

        do {
            guard let data = storage.data(forKey: StorageKeys.inAppMessages.rawValue) else {
                return []
            }
            
            let decodedInApps = try JSONDecoder().decode([Message].self, from: data)
            return decodedInApps
        } catch {
            ErrorLogger.shared.capture(error: error)
            return []
        }
    }
    
    func saveInAppMessages(messages: [Message]) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            let encodedMessages = try JSONEncoder().encode(messages)
            storage.set(encodedMessages, forKey: StorageKeys.inAppMessages.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }

    // MARK: In App Message Contents
    
    func getInAppMessageContents() -> [InAppContent] {
        guard let storage = storageUnwrapper() else { return [] }

        do {
            guard let data = storage.data(forKey: StorageKeys.inAppMessageContents.rawValue) else {
                return []
            }
            
            let decodedInAppContents = try JSONDecoder().decode([InAppContent].self, from: data)
            return decodedInAppContents
        } catch {
            ErrorLogger.shared.capture(error: error)
            return []
        }
    }
    
    func saveInAppMessageContents(contents: [InAppContent]) {
        guard let storage = storageUnwrapper() else { return }
        
        do {
            let encodedInAppContents = try JSONEncoder().encode(contents)
            storage.set(encodedInAppContents, forKey: StorageKeys.inAppMessageContents.rawValue)
        } catch {
            ErrorLogger.shared.capture(error: error)
        }
    }
}

// MARK: StorageDoesNotExistError

struct StorageDoesNotExistError: Error {}

extension StorageDoesNotExistError: LocalizedError {
    
    var errorDescription: String? {
        "Storage doesn't exist"
    }
    
}
