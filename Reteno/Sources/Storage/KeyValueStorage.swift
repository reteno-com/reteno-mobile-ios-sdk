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
}

// MARK: StorageDoesNotExistError

struct StorageDoesNotExistError: Error {}

extension StorageDoesNotExistError: LocalizedError {
    
    var errorDescription: String? {
        "Storage doesn't exist"
    }
    
}
