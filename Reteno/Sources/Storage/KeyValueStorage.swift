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
    case baseDeviceId = "com.reteno.base-device-id.key"
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
    case slideUpBaseHTMLVersion = "com.reteno.slide_up_base_html.key"
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
    case inAppCacheVersion = "com.reteno.in-app-cache-version.key"
    case sessionId = "com.reteno.session-id.key"
    case applicationOpenedCount = "com.reteno.application-opened-count.key"
    case applicationBackgroundedCount = "com.reteno.application-backgrounded-count.key"
    case previousVersion = "com.reteno.previous-version.key"
    case previousBuild = "com.reteno.previous-build.key"
    case automaticAppLifecycleReportingEnabled = "com.reteno.automatic-app-lifecycle-reporting.key"
    case applicationForegroundLifecycleReportingEnabled = "com.reteno.application-foreground-lifecycle-reporting.key"
    case automaticPushSubscriptionReportingEnabled = "com.reteno.automatic-push-subsription-reporting.key"
    case automaticSessionReportingEnabled = "com.reteno.automatic-session-reporting.key"
    case automaticSessionEndReportingEnabled = "com.reteno.automatic-session-end-reporting.key"
    case sessionInactivityDuration = "com.reteno.session-inactivity-duration.key"
    case retenoConfiguration = "com.reteno.reteno-configuration.key"
    case isDelayedInitialization = "com.reteno.reteno-delayed-initialization.key"
    case lastBaseHTMLFetchDate = "com.reteno.last-base-html-fetch-date.key"
    case lastBaseHTMLPath = "com.reteno.last-base-html-path.key"
}

final class KeyValueStorage {
    
    static let defaultStorage = UserDefaults(suiteName: "group.\(BundleIdHelper.getMainAppBundleId()).reteno-local-storage")
    
    private let storage: UserDefaults?
    
    init(storage: UserDefaults? = KeyValueStorage.defaultStorage) {
        self.storage = storage
    }
    
    func set(value: String, forKey key: String) {
        storageUnwrapper()?.setValue(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> String? {
        storageUnwrapper()?.string(forKey: key)
    }
    
    func set(value: Bool, forKey key: String) {
        storageUnwrapper()?.setValue(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Bool {
        storageUnwrapper()?.bool(forKey: key) ?? false
    }
    
    func set(value: Double, forKey key: String) {
        storageUnwrapper()?.set(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Double? {
        storageUnwrapper()?.double(forKey: key)
    }
    
    func set(value: Int, forKey key: String) {
        storageUnwrapper()?.set(value, forKey: key)
    }
    
    func getValue(forKey key: String) -> Int? {
        storageUnwrapper()?.integer(forKey: key)
    }
    
    func removeValue(forKey key: String) {
        storageUnwrapper()?.removeObject(forKey: key)
    }
    
    // MARK: Analytics logic

    func getStoredSessionConfiguration() -> RetenoSessionConfiguration? {
        guard let storage = storageUnwrapper() else { return nil }
        guard storage.object(forKey: StorageKeys.sessionInactivityDuration.rawValue) != nil else {
            return nil
        }
        
        return RetenoSessionConfiguration(
            sessionDuration: storage.double(forKey: StorageKeys.sessionInactivityDuration.rawValue),
            isSessionStartReportingEnabled: storage.bool(forKey: StorageKeys.automaticSessionReportingEnabled.rawValue),
            isSessionEndReportingEnabled: storage.bool(forKey: StorageKeys.automaticSessionEndReportingEnabled.rawValue)
        )
    }

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
            configuration.isApplicationForegroundLifecycleReportingEnabled,
            forKey: StorageKeys.applicationForegroundLifecycleReportingEnabled.rawValue
        )
        storage.setValue(
            configuration.isAutomaticPushSubscriptionReportingEnabled,
            forKey: StorageKeys.automaticPushSubscriptionReportingEnabled.rawValue
        )
        storage.setValue(
            configuration.sessionConfiguration.isSessionStartReportingEnabled,
            forKey: StorageKeys.automaticSessionReportingEnabled.rawValue
        )
        storage.setValue(
            configuration.sessionConfiguration.isSessionEndReportingEnabled,
            forKey: StorageKeys.automaticSessionEndReportingEnabled.rawValue
        )
        storage.set(
            configuration.sessionConfiguration.sessionDuration,
            forKey: StorageKeys.sessionInactivityDuration.rawValue
        )
    }

    // MARK: Events logic
    
    func addEvent(_ event: Event) {
        updateCollection(StorageKeys.events, empty: [Event]()) { $0.append(event) }
    }
    
    func getEvents() -> [Event] {
        readCollection(StorageKeys.events, empty: [Event]())
    }
    
    func clearEventsCache() {
        removeCollection(StorageKeys.events)
    }
    
    func clearEvents(_ events: [Event]) {
        let idForRemove = Set(events.map { $0.id })
        updateCollection(StorageKeys.events, empty: [Event]()) { $0.removeAll(where: { idForRemove.contains($0.id) }) }
    }
    
    // MARK: NotificationStatus logic
    
    func addNotificationStatus(_ model: NotificationStatus) {
        updateCollection(StorageKeys.notificationStatuses, empty: [NotificationStatus]()) { $0.append(model) }
    }
    
    func getNotificationStatuses() -> [NotificationStatus] {
        readCollection(StorageKeys.notificationStatuses, empty: [NotificationStatus]())
    }
    
    func clearNotificationStatus(_ model: NotificationStatus) {
        updateCollection(StorageKeys.notificationStatuses, empty: [NotificationStatus]()) {
            $0.removeAll(where: { $0.id == model.id })
        }
    }
    
    func clearOldNotificationStatusesCache() {
        updateCollection(StorageKeys.notificationStatuses, empty: [NotificationStatus]()) {
            $0.removeAll(where: { !$0.isValid })
        }
    }
    
    // MARK: Users logic
    
    func addUser(_ user: User) {
        updateCollection(StorageKeys.users, empty: [User]()) { $0.append(user) }
    }
    
    func getUsers() -> [User] {
        readCollection(StorageKeys.users, empty: [User]())
    }
    
    func clearUser(_ user: User) {
        updateCollection(StorageKeys.users, empty: [User]()) { $0.removeAll(where: { $0.id == user.id }) }
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
        storageUnwrapper()?.set(nil, forKey: StorageKeys.cachedUser.rawValue)
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
        storageUnwrapper()?.set(nil, forKey: StorageKeys.cachedDevice.rawValue)
    }
    
    // MARK: Recom events logic
    
    func addRecomEvent(_ event: RecomEvents) {
        updateCollection(StorageKeys.recomEvents, empty: [RecomEvents]()) { $0.append(event) }
    }
    
    func getRecomEvents() -> [RecomEvents] {
        readCollection(StorageKeys.recomEvents, empty: [RecomEvents]())
    }
    
    func clearRecomEventsCache() {
        removeCollection(StorageKeys.recomEvents)
    }
    
    func clearRecomEvents(_ events: [RecomEvents]) {
        let idForRemove = Set(events.map { $0.id })
        updateCollection(StorageKeys.recomEvents, empty: [RecomEvents]()) {
            $0.removeAll(where: { idForRemove.contains($0.id) })
        }
    }
    
    // MARK: App inbox messages ids logic
    
    func addInboxOpenedMessagesIds(_ ids: [AppInboxMessageStorableId]) {
        updateCollection(StorageKeys.inboxOpenedMessagesIds, empty: [AppInboxMessageStorableId]()) { existingIds in
            let idsToAdd = ids.filter { item in
                !existingIds.contains { $0.id == item.id }
            }
            existingIds.append(contentsOf: idsToAdd)
        }
    }

    func getInboxOpenedMessagesIds() -> [AppInboxMessageStorableId] {
        readCollection(StorageKeys.inboxOpenedMessagesIds, empty: [AppInboxMessageStorableId]())
    }

    func clearInboxOpenedMessagesIds(_ ids: [AppInboxMessageStorableId]) {
        let idForRemove = Set(ids.map { $0.id })
        updateCollection(StorageKeys.inboxOpenedMessagesIds, empty: [AppInboxMessageStorableId]()) {
            $0.removeAll(where: { idForRemove.contains($0.id) })
        }
    }

    func clearInboxOpenedMessagesIdsCache() {
        removeCollection(StorageKeys.inboxOpenedMessagesIds)
    }
    
    // MARK: Wrapped links logic
    
    func appendLink(_ link: StorableLink) {
        updateCollection(StorageKeys.wrappedLinks, empty: [StorableLink]()) { $0.append(link) }
    }
    
    func getLinks() -> [StorableLink] {
        readCollection(StorageKeys.wrappedLinks, empty: [StorableLink]())
    }
    
    func clearLinks(_ links: [StorableLink]) {
        updateCollection(StorageKeys.wrappedLinks, empty: [StorableLink]()) { $0.removeAll(where: { links.contains($0) }) }
    }
    
    func clearAllLinks() {
        removeCollection(StorageKeys.wrappedLinks)
    }
    
    // MARK: Error
    
    func addErrorEvent(_ event: ErrorEvent) {
        updateCollection(StorageKeys.errorEvents, empty: [ErrorEvent](), reportsErrors: false) { $0.append(event) }
    }
    
    func getErrorEvents() -> [ErrorEvent] {
        readCollection(StorageKeys.errorEvents, empty: [ErrorEvent](), reportsErrors: false)
    }
    
    func clearErrorEvents(_ errorEvents: [ErrorEvent]) {
        let idForRemove = Set(errorEvents.map { $0.id })
        updateCollection(StorageKeys.errorEvents, empty: [ErrorEvent](), reportsErrors: false) {
            $0.removeAll(where: { idForRemove.contains($0.id) })
        }
    }
    
    func clearAllErrorEvents() {
        removeCollection(StorageKeys.errorEvents, reportsErrors: false)
    }
    
    // MARK: Only once - Displayed inApp ids
    
    func getOnlyOnceDisplayedInAppIds() -> [Int] {
        readCollection(StorageKeys.onlyOnceInApps, empty: [Int]())
    }
    
    func addOnlyOnceDisplayedId(id: Int) {
        updateCollection(StorageKeys.onlyOnceInApps, empty: [Int]()) { $0.append(id) }
    }
    
    // MARK: No Limit - Displayed inApp ids
    
    func getNoLimitDisplayedInAppIds() -> [Int] {
        readCollection(StorageKeys.noLimitInApps, empty: [Int]())
    }
    
    func addNoLimitDisplayedId(id: Int) {
        updateCollection(StorageKeys.noLimitInApps, empty: [Int]()) { $0.append(id) }
    }
    
    func clearNoLimitEvents() {
        removeCollection(StorageKeys.noLimitInApps)
    }
    
    // MARK: Once per session - Displayed inApp ids
    
    func getOncePerSessionDisplayedInAppIds() -> [Int] {
        readCollection(StorageKeys.oncePerSessionInApps, empty: [Int]())
    }
    
    func addOncePerSessionDisplayedId(id: Int) {
        updateCollection(StorageKeys.oncePerSessionInApps, empty: [Int]()) { $0.append(id) }
    }
    
    func clearOncePerSessionEvents() {
        removeCollection(StorageKeys.oncePerSessionInApps)
    }
    
    // MARK: Min Interval - Displayed inApp Id and Date
    
    func getMinIntervalInApps() -> [Int: Date] {
        readCollection(StorageKeys.minIntervalValue, empty: [Int: Date]())
    }
    
    func addMinIntervalInApps(id: Int) {
        let date = Date()
        updateCollection(StorageKeys.minIntervalValue, empty: [Int: Date]()) { $0[id] = date }
    }
    
    // MARK: Time Per Time Unit
    
    func getTimePerTimeUnitInApps() -> [Int: [Date]] {
        readCollection(StorageKeys.timePerUnitInApps, empty: [Int: [Date]]())
    }
    
    func addTimePerTimeUnitInApps(id: Int) {
        let date = Date()
        updateCollection(StorageKeys.timePerUnitInApps, empty: [Int: [Date]]()) { $0[id, default: []].append(date) }
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

    func clearInApps() {
        guard let storage = storageUnwrapper() else { return }
        storage.set([], forKey: StorageKeys.inAppMessages.rawValue)
        storage.set([], forKey: StorageKeys.inAppMessageContents.rawValue)
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
    
    // MARK: Collections
    
    private func readCollection<T: Decodable>(_ key: StorageKeys, empty: T, reportsErrors: Bool = true) -> T {
        guard let storage = storageUnwrapper(reportsErrors: reportsErrors),
              let data = PendingWritesStore.shared.data(forKey: key.rawValue, in: storage) else {
            return empty
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            if reportsErrors {
                ErrorLogger.shared.capture(error: error)
            }
            
            return empty
        }
    }
    
    private func updateCollection<T: Codable>(
        _ key: StorageKeys,
        empty: T,
        reportsErrors: Bool = true,
        _ modify: (inout T) -> Void
    ) {
        guard let storage = storageUnwrapper(reportsErrors: reportsErrors) else { return }
        
        var errors: [Error] = []
        PendingWritesStore.shared.update(forKey: key.rawValue, in: storage) { data in
            var value = empty
            if let data = data {
                do {
                    value = try JSONDecoder().decode(T.self, from: data)
                } catch {
                    errors.append(error)
                }
            }
            modify(&value)
            
            do {
                return try JSONEncoder().encode(value)
            } catch {
                errors.append(error)
                
                return data
            }
        }
        
        if reportsErrors {
            errors.forEach { ErrorLogger.shared.capture(error: $0) }
        }
    }
    
    private func removeCollection(_ key: StorageKeys, reportsErrors: Bool = true) {
        guard let storage = storageUnwrapper(reportsErrors: reportsErrors) else { return }
        
        PendingWritesStore.shared.update(forKey: key.rawValue, in: storage) { _ in nil }
    }
    
    private func storageUnwrapper(reportsErrors: Bool = true) -> UserDefaults? {
        guard let storage = storage else {
            if reportsErrors {
                ErrorLogger.shared.capture(error: StorageDoesNotExistError())
            }
            
            return nil
        }
        
        return storage
    }
}

// MARK: PendingWritesStore

private final class PendingWritesStore {
    
    static let shared = PendingWritesStore()
    
    private struct Key: Hashable {
        let storage: ObjectIdentifier
        let key: String
    }
    
    private struct PendingWrite {
        let storage: UserDefaults
        let key: String
        let value: Data?
        let version: UInt64
    }
    
    private let lock = NSLock()
    private var pendingWrites: [Key: PendingWrite] = [:]
    private var version: UInt64 = 0
    private var isFlushing = false
    
    func data(forKey key: String, in storage: UserDefaults) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        
        return committedData(forKey: key, in: storage)
    }
    
    func update(forKey key: String, in storage: UserDefaults, _ transform: (Data?) -> Data?) {
        lock.lock()
        let value = transform(committedData(forKey: key, in: storage))
        version &+= 1
        pendingWrites[Key(storage: ObjectIdentifier(storage), key: key)] = PendingWrite(
            storage: storage,
            key: key,
            value: value,
            version: version
        )
        let shouldFlush = !isFlushing
        isFlushing = true
        lock.unlock()
        
        if shouldFlush {
            flush()
        }
    }
    
    private func committedData(forKey key: String, in storage: UserDefaults) -> Data? {
        if let pendingWrite = pendingWrites[Key(storage: ObjectIdentifier(storage), key: key)] {
            return pendingWrite.value
        }
        
        return storage.data(forKey: key)
    }
    
    private func flush() {
        while true {
            lock.lock()
            let writes = Array(pendingWrites.values)
            guard writes.isNotEmpty else {
                isFlushing = false
                lock.unlock()
                
                return
            }
            lock.unlock()
            
            writes.forEach { $0.storage.set($0.value, forKey: $0.key) }
            
            lock.lock()
            for write in writes {
                let key = Key(storage: ObjectIdentifier(write.storage), key: write.key)
                if pendingWrites[key]?.version == write.version {
                    pendingWrites[key] = nil
                }
            }
            lock.unlock()
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
