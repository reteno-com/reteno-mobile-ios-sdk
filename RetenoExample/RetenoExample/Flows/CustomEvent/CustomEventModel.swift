//
//  CustomEventModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class CustomEventModel {
    
    var scheduledEvents: [ScheduledCustomEvent] { scheduler.scheduledEvents }
    
    private let scheduler: CustomEventScheduler
    
    init(scheduler: CustomEventScheduler = .shared) {
        self.scheduler = scheduler
    }
    
    func logEvent(eventTypeKey: String, parameters: [CustomEventParameter]) {
        Reteno.logEvent(
            eventTypeKey: eventTypeKey,
            date: Date(),
            parameters: parameters.map { $0.eventParameter },
            forcePush: true
        )
    }
    
    func scheduleEvent(
        eventTypeKey: String,
        parameters: [CustomEventParameter],
        hour: Int,
        minute: Int,
        repeatMode: ScheduleRepeatMode
    ) -> ScheduledCustomEvent? {
        scheduler.schedule(
            eventName: eventTypeKey,
            parameters: parameters,
            hour: hour,
            minute: minute,
            repeatMode: repeatMode
        )
    }
    
    func cancelScheduledEvent(id: UUID) {
        scheduler.cancelSchedule(id: id)
    }
}
