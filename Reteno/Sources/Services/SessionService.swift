//
//  SessionService.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 02.02.2024.
//

import UIKit
import Foundation

final class SessionService {

    private let storage = StorageBuilder.build()
    private var isSessionStartEventReportingEnabled: Bool
    private var isSessionEndEventReportingEnabled: Bool
    private var sessionInactivityDuration: TimeInterval
    
    private var timeInApp: Int = 0
    var timeSpendInApp: ((Int) -> Void)? {
        didSet {
            guard timeSpendInApp != nil else { return }
            storage.set(value: 0, forKey: StorageKeys.sessionDuration.rawValue)
            sessionDurationTimer()
        }
    }
    
    private var sesionTimer: Timer?
    
    init() {
        self.isSessionStartEventReportingEnabled = storage.getValue(forKey: StorageKeys.automaticSessionReportingEnabled.rawValue)
        self.isSessionEndEventReportingEnabled = storage.getValue(forKey: StorageKeys.automaticSessionEndReportingEnabled.rawValue)
        let storedDuration: Double? = storage.getValue(forKey: StorageKeys.sessionInactivityDuration.rawValue)
        self.sessionInactivityDuration = storedDuration ?? RetenoSessionConfiguration.default.sessionDuration
    }

    func reconfigure(
        previous: RetenoSessionConfiguration?,
        new configuration: RetenoSessionConfiguration
    ) {
        guard let previous = previous else {
            applyInMemoryConfiguration(configuration)
            return
        }

        guard !isConfiguration(previous, equalTo: configuration) else {
            applyInMemoryConfiguration(configuration)
            return
        }

        sendEndSessionEventIfNeeded(
            inactivityDuration: previous.sessionDuration,
            isReportingEnabled: previous.isSessionEndReportingEnabled
        )
        invalidateTimer()

        applyInMemoryConfiguration(configuration)

        setLastActivityDate()
        startSession()
        sessionDurationTimer()
    }

    private func applyInMemoryConfiguration(_ configuration: RetenoSessionConfiguration) {
        isSessionStartEventReportingEnabled = configuration.isSessionStartReportingEnabled
        isSessionEndEventReportingEnabled = configuration.isSessionEndReportingEnabled
        sessionInactivityDuration = configuration.sessionDuration
    }

    private func isConfiguration(
        _ lhs: RetenoSessionConfiguration,
        equalTo rhs: RetenoSessionConfiguration
    ) -> Bool {
        lhs.sessionDuration == rhs.sessionDuration
            && lhs.isSessionStartReportingEnabled == rhs.isSessionStartReportingEnabled
            && lhs.isSessionEndReportingEnabled == rhs.isSessionEndReportingEnabled
    }
    
    // MARK: Session duration timer
    
    func sessionDurationTimer() {
        invalidateTimer()
        timeInApp = Int(storage.getValue(forKey: StorageKeys.sessionDuration.rawValue) ?? 0)
        sesionTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { [weak self] _ in
                guard let self = self else { return }
                
                self.timeInApp += 1
                self.timeSpendInApp?(self.timeInApp)
                self.storage.set(value: self.timeInApp, forKey: StorageKeys.sessionDuration.rawValue)
                self.restartSessionNeeded()
            }
        )
    }

    private func restartSessionNeeded() {
        guard sessionInactivityDuration > 0,
              TimeInterval(timeInApp) >= sessionInactivityDuration
        else { return }

        let now = Date()
        sendEndSessionEventIfNeeded(
            inactivityDuration: sessionInactivityDuration,
            isReportingEnabled: isSessionEndEventReportingEnabled,
            endDate: now
        )

        timeInApp = 0
        storage.set(value: 0, forKey: StorageKeys.sessionDuration.rawValue)
        storage.set(value: now.timeIntervalSince1970, forKey: StorageKeys.lastActivityDate.rawValue)
        startSession()
    }
    
    func invalidateTimer() {
        sesionTimer?.invalidate()
        sesionTimer = nil
        timeInApp = 0
    }
    
    // MARK: Subscribe on notifications
    
    func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationWillTerminateNotification(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationDidEnterBackgroundNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func setLastActivityDate() {
        storage.set(value: Date().timeIntervalSince1970, forKey: StorageKeys.lastActivityDate.rawValue)
    }
    
    private func checkForActiveSession() {
        let lastActivityDate: Double? = storage.getValue(forKey: StorageKeys.lastActivityDate.rawValue)
        guard let lastActivityDate = lastActivityDate else {
            self.startSession()
            return
        }
        
        let date = Date(timeIntervalSince1970: lastActivityDate)
        if Date().timeIntervalSince(date) >= sessionInactivityDuration {
            self.sendEndSessionEventIfNeeded()
            self.startSession()
        }
        setLastActivityDate()
    }
    
    func startSession() {
        storage.clearOncePerSessionEvents()
        storage.clearNoLimitEvents()
        storage.set(value: 0, forKey: StorageKeys.sessionDuration.rawValue)
        
        sendStartSessionEventIfNeeded()
    }
    
    func sendStartSessionEventIfNeeded() {
        guard isSessionStartEventReportingEnabled else { return }
        
        storage.set(value: 0, forKey: StorageKeys.applicationOpenedCount.rawValue)
        storage.set(value: 0, forKey: StorageKeys.applicationBackgroundedCount.rawValue)

        let sessionId = UUID().uuidString
        let startDate = DateFormatter.baseBEDateFormatter.string(from: Date())
        storage.set(value: sessionId, forKey: StorageKeys.sessionId.rawValue)

        Reteno.logEvent(
            eventTypeKey: SessionKeys.sessionStartedKey.rawValue,
            parameters: [
                .init(name: SessionKeys.startDateKey.rawValue, value: startDate),
                .init(name: SessionKeys.sessionIdKey.rawValue, value: sessionId)
            ],
            forcePush: true
        )
    }
    
    func sendEndSessionEventIfNeeded() {
        sendEndSessionEventIfNeeded(
            inactivityDuration: sessionInactivityDuration,
            isReportingEnabled: isSessionEndEventReportingEnabled
        )
    }

    private func sendEndSessionEventIfNeeded(
        inactivityDuration: TimeInterval,
        isReportingEnabled: Bool,
        endDate: Date? = nil
    ) {
        guard isReportingEnabled,
              let sessionId: String = storage.getValue(forKey: StorageKeys.sessionId.rawValue),
              let lastActivityTimestamp: Double = storage.getValue(forKey: StorageKeys.lastActivityDate.rawValue)
        else {
            return
        }
        
        let resolvedEndDate = endDate
            ?? Date(timeIntervalSince1970: lastActivityTimestamp).addingTimeInterval(inactivityDuration)
        let endDateString = DateFormatter.baseBEDateFormatter.string(from: resolvedEndDate)
        let duration = Int(storage.getValue(forKey: StorageKeys.sessionDuration.rawValue) ?? 0)
        let durationString = String(duration)
        let openedEventCount = String(storage.getValue(forKey: StorageKeys.applicationOpenedCount.rawValue) ?? 0)
        let backgroundedEventCount = String(storage.getValue(forKey: StorageKeys.applicationBackgroundedCount.rawValue) ?? 0)

        
        Reteno.logEvent(
            eventTypeKey: SessionKeys.sessionEndedKey.rawValue,
            parameters: [
                .init(name: SessionKeys.endDateKey.rawValue, value: endDateString),
                .init(name: SessionKeys.sessionIdKey.rawValue, value: sessionId),
                .init(name: SessionKeys.durationInSecondsKey.rawValue, value: durationString),
                .init(name: SessionKeys.openedCountKey.rawValue, value: openedEventCount),
                .init(name: SessionKeys.backgroundedCount.rawValue, value: backgroundedEventCount)
            ],
            forcePush: true
        )
    }
    
    // MARK: Application open counted event
    
    private func updateApplicationOpenedEventCount() {
        let count: Int = storage.getValue(forKey: StorageKeys.applicationOpenedCount.rawValue) ?? 0
        storage.set(value: count + 1, forKey: StorageKeys.applicationOpenedCount.rawValue)
    }
    
    private func updateApplicationBackgorundedEventCount() {
        let count: Int = storage.getValue(forKey: StorageKeys.applicationBackgroundedCount.rawValue) ?? 0
        storage.set(value: count + 1, forKey: StorageKeys.applicationBackgroundedCount.rawValue)
    }
    
    // MARK: Handle notifications
    
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
        updateApplicationOpenedEventCount()
        checkForActiveSession()
        sessionDurationTimer()
    }
    
    @objc
    private func handleApplicationWillTerminateNotification(_ notification: Notification) {
        setLastActivityDate()
        invalidateTimer()
    }

    @objc
    private func handleApplicationDidEnterBackgroundNotification(_ notification: Notification) {
        updateApplicationBackgorundedEventCount()
        setLastActivityDate()
        invalidateTimer()
    }
}

fileprivate enum SessionKeys: String {
    case sessionStartedKey = "SessionStarted"
    case sessionEndedKey = "SessionEnded"
    case sessionIdKey = "sessionID"
    case startDateKey = "startTime"
    case endDateKey = "endTime"
    case durationInSecondsKey = "durationInSeconds"
    case openedCountKey = "applicationOpenedCount"
    case backgroundedCount = "applicationBackgroundedCount"
}
