//
//  Reteno.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import Foundation
import UserNotifications

public struct Reteno {
    
    static var version = "0.2.1"
    
    @available(iOSApplicationExtension, unavailable)
    public static let userNotificationService = UserNotificationService.shared
    
    static var screenViewAnalyticsService: ScreenViewAnalyticsService!
    
    private init() {}
    
    public static func start(apiKey: String, isAutomaticScreenReportingEnabled: Bool = true) {
        DeviceIdHelper.actualizeDeviceId()
        ApiKeyHelper.setApiKey(apiKey)
        screenViewAnalyticsService = ScreenViewAnalyticsService(
            isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled,
            service: MobileRequestServiceBuilder.build()
        )
    }
    
    public static func logEvent(eventTypeKey: String, date: Date = Date(), parameters: [Event.Parameter]) {
        screenViewAnalyticsService.logEvent(eventTypeKey: eventTypeKey, date: date, parameters: parameters)
    }
    
}
