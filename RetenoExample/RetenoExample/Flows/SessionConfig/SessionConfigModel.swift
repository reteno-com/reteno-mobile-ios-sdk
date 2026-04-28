//
//  SessionConfigModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 16.04.2026.
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

enum SessionConfigUserDefaultsKey {
    static let sessionDuration = "SessionConfig.sessionDuration"
    static let isSessionStartReportingEnabled = "SessionConfig.isSessionStartReportingEnabled"
    static let isSessionEndReportingEnabled = "SessionConfig.isSessionEndReportingEnabled"
    static let isApplicationForegroundLifecycleReportingEnabled = "SessionConfig.isApplicationForegroundLifecycleReportingEnabled"
}

final class SessionConfigModel {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var sessionDuration: TimeInterval {
        userDefaults.double(forKey: SessionConfigUserDefaultsKey.sessionDuration)
    }
    
    var isSessionStartReportingEnabled: Bool {
        userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isSessionStartReportingEnabled)
    }
    
    var isSessionEndReportingEnabled: Bool {
        userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isSessionEndReportingEnabled)
    }
    
    var isApplicationForegroundLifecycleReportingEnabled: Bool {
        userDefaults.bool(forKey: SessionConfigUserDefaultsKey.isApplicationForegroundLifecycleReportingEnabled)
    }
    
    func save(
        sessionDuration: TimeInterval,
        isSessionStartReportingEnabled: Bool,
        isSessionEndReportingEnabled: Bool,
        isApplicationForegroundLifecycleReportingEnabled: Bool
    ) {
        userDefaults.set(sessionDuration, forKey: SessionConfigUserDefaultsKey.sessionDuration)
        userDefaults.set(isSessionStartReportingEnabled, forKey: SessionConfigUserDefaultsKey.isSessionStartReportingEnabled)
        userDefaults.set(isSessionEndReportingEnabled, forKey: SessionConfigUserDefaultsKey.isSessionEndReportingEnabled)
        userDefaults.set(
            isApplicationForegroundLifecycleReportingEnabled,
            forKey: SessionConfigUserDefaultsKey.isApplicationForegroundLifecycleReportingEnabled
        )
    }
}
