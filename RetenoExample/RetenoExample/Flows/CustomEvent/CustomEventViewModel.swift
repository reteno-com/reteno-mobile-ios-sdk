//
//  CustomEventViewModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class CustomEventViewModel {
    
    var onScheduledEventsChange: (() -> Void)?
    
    var scheduledEvents: [ScheduledCustomEvent] { model.scheduledEvents }
    
    private let model: CustomEventModel
    
    init(model: CustomEventModel) {
        self.model = model
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scheduledEventsDidChange),
            name: CustomEventScheduler.schedulesDidChangeNotification,
            object: nil
        )
    }
    
    func logEvent(eventTypeKey: String, parameters: [CustomEventParameter]) {
        model.logEvent(eventTypeKey: eventTypeKey, parameters: parameters)
    }
    
    func scheduleEvent(
        eventTypeKey: String,
        parameters: [CustomEventParameter],
        hour: Int,
        minute: Int,
        repeatMode: ScheduleRepeatMode
    ) -> ScheduledCustomEvent? {
        model.scheduleEvent(
            eventTypeKey: eventTypeKey,
            parameters: parameters,
            hour: hour,
            minute: minute,
            repeatMode: repeatMode
        )
    }
    
    func cancelScheduledEvent(id: UUID) {
        model.cancelScheduledEvent(id: id)
    }
    
    @objc
    private func scheduledEventsDidChange() {
        DispatchQueue.main.async { [weak self] in
            self?.onScheduledEventsChange?()
        }
    }
}
