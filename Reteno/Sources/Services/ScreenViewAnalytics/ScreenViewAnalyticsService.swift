//
//  ScreenViewAnalyticsService.swift
//  Pods
//
//  Created by Anna Sahaidak on 29.09.2022.
//

import Foundation
import UIKit

public let ScreenViewEvent = "screen_view"
public let ScreenClass = "screen_class"

struct ScreenViewAnalyticsService {
    
    private let isAutomaticScreenReportingEnabled: Bool
    private let service: EventsSender
    
    init(isAutomaticScreenReportingEnabled: Bool, service: EventsSender) {
        self.isAutomaticScreenReportingEnabled = isAutomaticScreenReportingEnabled
        self.service = service
        
        if isAutomaticScreenReportingEnabled {
            startSwizzling()
        }
    }
    
    func logEvent(eventTypeKey: String = ScreenViewEvent, date: Date, parameters: [Event.Parameter]) {
        service.sendScreenViewEvent(eventTypeKey: eventTypeKey, date: date, params: parameters, completionHandler: { _ in })
    }
    
    private func startSwizzling() {
        UIViewController.swizzleViewDidAppear()
    }
    
}
