//
//  SDKStateHelper.swift
//  Reteno
//
//  Created by Serhii Navka on 25.09.2024.
//

import Foundation
import UserNotifications

class SDKStateHelper {
        
    var shouldCollectNotifications: Bool {
        !isInitialized && getIsDelayedInitialization()
    }
    private(set) var collectedNotifications: [UNNotification] = []
    private(set) var isInitialized: Bool = false

    
    private let storage: KeyValueStorage
    
    init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    func set(isInitialized: Bool) {
        self.isInitialized = isInitialized
    }
    
    func getIsDelayedInitialization() -> Bool {
        storage.getIsDelayedInitialization()
    }
    
    func set(isDelayedInitialization: Bool) {
        storage.set(isDelayedInitialization: isDelayedInitialization)
    }
    
    func collect(notification: UNNotification) {
        collectedNotifications.append(notification)
    }
    
    func popLastAndClearNotifications() -> UNNotification? {
        let last = collectedNotifications.last
        collectedNotifications = []
        
        return last
    }
}
