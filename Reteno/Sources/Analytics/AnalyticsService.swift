//
//  AnalyticsService.swift
//  Pods
//
//  Created by Anna Sahaidak on 29.09.2022.
//

import Foundation
import UIKit
import UserNotifications

public let ScreenViewEvent = "screenView"
public let ScreenClass = "screenClass"

struct AnalyticsService {
    
    /// Flag that indicates if automatic screen view tracking enabled
    private let isAutomaticScreenReportingEnabled: Bool
    /// Local storage, based on `UserDefaults`
    private let storage: KeyValueStorage
    private let lifecycleAnalyticsService: AppLifecycleAnalyticsSevice?
    
    init(
        isAutomaticScreenReportingEnabled: Bool,
        isAutomaticAppLifecycleReportingEnabled: Bool,
        storage: KeyValueStorage = StorageBuilder.build()
    ) {
        self.isAutomaticScreenReportingEnabled = isAutomaticScreenReportingEnabled
        self.storage = storage
        if isAutomaticAppLifecycleReportingEnabled {
            self.lifecycleAnalyticsService = AppLifecycleAnalyticsSevice()
            self.lifecycleAnalyticsService?.subscribeOnNotifications()
        } else {
            self.lifecycleAnalyticsService = nil
        }
        
        if isAutomaticScreenReportingEnabled {
            startSwizzling()
        }
        UNUserNotificationCenter.swizzleRequestAuthorizationMethod()
    }
    
    /// Log events
    /// - Parameter eventTypeKey: Event type ID
    /// - Parameter date: Time when event occurred
    /// - Parameter parameters: List of event parameters as array of "key" - "value" pairs. Parameter keys are arbitrary. Used in campaigns and for dynamic content creation in messages.
    func logEvent(eventTypeKey: String = ScreenViewEvent, date: Date, parameters: [Event.Parameter]) {
        storage.addEvent(Event(eventTypeKey: eventTypeKey, date: date, parameters: parameters))
    }
    
    /// Start swizzling `UIViewController` lifecycle methods
    private func startSwizzling() {
        UIViewController.swizzleViewDidAppear()
    }
    
}
