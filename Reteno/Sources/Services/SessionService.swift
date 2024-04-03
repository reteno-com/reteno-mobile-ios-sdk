//
//  SessionService.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 02.02.2024.
//

import UIKit
import Foundation

fileprivate let sessionStartedKey = "SessionStarted"
fileprivate let startDateKey = "startDate"
fileprivate let sessionIdKey = "sessionId"

final class SessionService {
    
    private let storage = StorageBuilder.build()
    
    private var timeInApp: Int = 0
    var timeSpendInApp: ((Int) -> Void)?
    
    private var sesionTimer: Timer?
    
    // MARK: Session duration timer
    
    private func sessionDurationTimer() {
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
            }
        )
    }
    
    private func invalidateTimer() {
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
        if Date().minutes(from: date) >= 5 {
            self.startSession()
        }
        setLastActivityDate()
    }
    
    private func startSession() {
        storage.clearOncePerSessionEvents()
        storage.clearNoLimitEvents()
        storage.set(value: 0, forKey: StorageKeys.sessionDuration.rawValue)

        let sessionId = UUID().uuidString
        let startDate = DateFormatter.baseBEDateFormatter.string(from: Date())
        storage.set(value: sessionId, forKey: StorageKeys.sessionId.rawValue)

        Reteno.logEvent(
            eventTypeKey: sessionStartedKey,
            parameters: [
                .init(name: startDateKey, value: startDate),
                .init(name: sessionIdKey, value: sessionId)
            ]
        )
    }
    
    // MARK: Handle notifications
    
    @objc
    private func handleApplicationDidBecomeActiveNotification(_ notification: Notification) {
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
        setLastActivityDate()
        invalidateTimer()
    }
}
