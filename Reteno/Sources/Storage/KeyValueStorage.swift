//
//  KeyValueStorage.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 21.09.2022.
//

import Foundation

enum StorageKeys: String, CaseIterable {
    
    case pushToken = "com.reteno.push-token.key"
    case deviceId = "com.reteno.device-id.key"
    case customDeviceId = "com.reteno.custom-device-id.key"
    case externalUserId = "com.reteno.external-user-id.key"
    case apiKey = "com.reteno.api-key.key"
    case events = "com.reteno.events.key"
    case notificationStatuses = "com.reteno.notification-statuses.key"
    case users = "com.reteno.users.key"
    case debugModeFlag = "com.reteno.debug-mode-flag.key"
    
}

final class KeyValueStorage {
    
    private let storage: UserDefaults?
    
    init(storage: UserDefaults? = UserDefaults(suiteName:  "group.\(BundleIdHelper.getMainAppBundleId()).reteno-local-storage")) {
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
            SentryHelper.capture(error: error)
        }
    }
    
    func getEvents() -> [Event] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.events.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
            
            return decodedEvents
        } catch {
            SentryHelper.capture(error: error)
            
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
            SentryHelper.capture(error: error)
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
            SentryHelper.capture(error: error)
        }
    }
    
    func getNotificationStatuses() -> [NotificationStatus] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.notificationStatuses.rawValue) else { return [] }
            
            let decodedEvents = try JSONDecoder().decode([NotificationStatus].self, from: data)
            
            return decodedEvents
        } catch {
            SentryHelper.capture(error: error)
            
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
            SentryHelper.capture(error: error)
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
            SentryHelper.capture(error: error)
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
            SentryHelper.capture(error: error)
        }
    }
    
    func getUsers() -> [User] {
        guard let storage = storageUnwrapper() else { return [] }
        
        do {
            guard let data = storage.data(forKey: StorageKeys.users.rawValue) else { return [] }
            
            let decodedUsers = try JSONDecoder().decode([User].self, from: data)
            
            return decodedUsers
        } catch {
            SentryHelper.capture(error: error)
            
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
            SentryHelper.capture(error: error)
        }
    }
    
    private func storageUnwrapper() -> UserDefaults? {
        guard let storage = storage else {
            SentryHelper.capture(error: StorageDoesNotExistError())
            
            return nil
        }
        
        return storage
    }
    
}

// MARK: - StorageDoesNotExistError

struct StorageDoesNotExistError: Error {}

extension StorageDoesNotExistError: LocalizedError {
    
    var errorDescription: String? {
        "Storage doesn't exist"
    }
    
}
