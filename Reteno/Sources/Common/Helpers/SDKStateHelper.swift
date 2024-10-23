//
//  SDKStateHelper.swift
//  Reteno
//
//  Created by Serhii Navka on 25.09.2024.
//

import Foundation
import UserNotifications

class SDKStateHelper {
    
    static var shared: SDKStateHelper = .init()
        
    var shouldCollectNotifications: Bool {
        !isInitialized && IsDelayedInitialization
    }
    private(set) var collectedNotifications: [UNNotification] = []
    private(set) var isInitialized: Bool = false
    private(set) var IsDelayedInitialization: Bool = false

    private init() {}
    
    func set(isInitialized: Bool) {
        self.isInitialized = isInitialized
    }
    
    func set(isDelayedInitialization: Bool) {
        self.IsDelayedInitialization = isDelayedInitialization
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
