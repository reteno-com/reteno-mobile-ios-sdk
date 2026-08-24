//
//  ScheduledCustomEvent.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

struct CustomEventParameter: Codable, Equatable {
    
    let name: String
    let value: String
    
    var eventParameter: Event.Parameter {
        Event.Parameter(name: name, value: value)
    }
}

enum ScheduleRepeatMode: String, Codable, CaseIterable {
    
    case once
    case daily
    
    var title: String {
        switch self {
        case .once:
            return NSLocalizedString("custom_event_screen.schedule.repeat_once", comment: "")
            
        case .daily:
            return NSLocalizedString("custom_event_screen.schedule.repeat_daily", comment: "")
        }
    }
}

struct ScheduledCustomEvent: Codable, Equatable {
    
    let id: UUID
    let eventName: String
    let parameters: [CustomEventParameter]
    let hour: Int
    let minute: Int
    let repeatMode: ScheduleRepeatMode
    var fireDate: Date
    
    var eventParameters: [Event.Parameter] {
        parameters.map { $0.eventParameter }
    }
    
    var scheduleDescription: String {
        switch repeatMode {
        case .once:
            return String(
                format: NSLocalizedString("custom_event_screen.scheduled_event.once", comment: ""),
                ScheduledCustomEvent.dateTimeFormatter.string(from: fireDate)
            )
            
        case .daily:
            return String(
                format: NSLocalizedString("custom_event_screen.scheduled_event.daily", comment: ""),
                ScheduledCustomEvent.timeFormatter.string(from: fireDate)
            )
        }
    }
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
    }()
}
