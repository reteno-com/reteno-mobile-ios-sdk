//
//  CustomEventScheduler.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import Reteno

final class CustomEventScheduler {
    
    static let shared = CustomEventScheduler()
    
    static let schedulesDidChangeNotification = Notification.Name("CustomEventScheduler.schedulesDidChange")
    static let didFireEventNotification = Notification.Name("CustomEventScheduler.didFireEvent")
    static let firedEventNameUserInfoKey = "firedEventName"
    
    private static let storageKey = "ScheduledCustomEvents"
    
    private(set) var scheduledEvents: [ScheduledCustomEvent]
    
    private let userDefaults: UserDefaults
    private var timer: Timer?
    
    private var calendar: Calendar { Calendar.current }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        if
            let data = userDefaults.data(forKey: CustomEventScheduler.storageKey),
            let events = try? JSONDecoder().decode([ScheduledCustomEvent].self, from: data)
        {
            scheduledEvents = events
        } else {
            scheduledEvents = []
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func start() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        fireDueEvents()
    }
    
    @discardableResult
    func schedule(
        eventName: String,
        parameters: [CustomEventParameter],
        hour: Int,
        minute: Int,
        repeatMode: ScheduleRepeatMode
    ) -> ScheduledCustomEvent? {
        guard let fireDate = nextDate(hour: hour, minute: minute, after: Date()) else { return nil }
        
        let event = ScheduledCustomEvent(
            id: UUID(),
            eventName: eventName,
            parameters: parameters,
            hour: hour,
            minute: minute,
            repeatMode: repeatMode,
            fireDate: fireDate
        )
        scheduledEvents.append(event)
        commitChanges()
        
        return event
    }
    
    func cancelSchedule(id: UUID) {
        scheduledEvents.removeAll { $0.id == id }
        commitChanges()
    }
    
    // MARK: - Firing
    
    @objc
    private func applicationDidBecomeActive() {
        fireDueEvents()
    }
    
    @objc
    private func timerFired() {
        fireDueEvents()
    }
    
    private func fireDueEvents() {
        let now = Date()
        var remainingEvents: [ScheduledCustomEvent] = []
        var hasFiredEvents = false
        
        for var event in scheduledEvents {
            guard event.fireDate <= now else {
                remainingEvents.append(event)
                continue
            }
            
            logEvent(event)
            hasFiredEvents = true
            
            guard
                event.repeatMode == .daily,
                let nextFireDate = nextDate(hour: event.hour, minute: event.minute, after: now)
            else { continue }
            
            event.fireDate = nextFireDate
            remainingEvents.append(event)
        }
        
        scheduledEvents = remainingEvents
        
        if hasFiredEvents {
            commitChanges()
        } else {
            restartTimer()
        }
    }
    
    private func logEvent(_ event: ScheduledCustomEvent) {
        Reteno.logEvent(
            eventTypeKey: event.eventName,
            date: Date(),
            parameters: event.eventParameters,
            forcePush: true
        )
        
        NotificationCenter.default.post(
            name: CustomEventScheduler.didFireEventNotification,
            object: self,
            userInfo: [CustomEventScheduler.firedEventNameUserInfoKey: event.eventName]
        )
    }
    
    // MARK: - Helpers
    
    private func commitChanges() {
        if let data = try? JSONEncoder().encode(scheduledEvents) {
            userDefaults.set(data, forKey: CustomEventScheduler.storageKey)
        }
        
        restartTimer()
        
        NotificationCenter.default.post(name: CustomEventScheduler.schedulesDidChangeNotification, object: self)
    }
    
    private func restartTimer() {
        timer?.invalidate()
        timer = nil
        
        guard let nextFireDate = scheduledEvents.map({ $0.fireDate }).min() else { return }
        
        let timer = Timer(
            fireAt: nextFireDate,
            interval: 0.0,
            target: self,
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: false
        )
        timer.tolerance = 1.0
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func nextDate(hour: Int, minute: Int, after date: Date) -> Date? {
        calendar.nextDate(
            after: date,
            matching: DateComponents(hour: hour, minute: minute),
            matchingPolicy: .nextTime
        )
    }
}
