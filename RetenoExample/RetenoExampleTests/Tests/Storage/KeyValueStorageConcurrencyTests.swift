//
//  KeyValueStorageConcurrencyTests.swift
//  RetenoExampleTests
//
//  Created by George on 06.08.2026.
//

import XCTest
@testable import Reteno

final class KeyValueStorageConcurrencyTests: XCTestCase {
    
    private let suiteName = "unit_tests_storage_concurrency"
    
    private var userDefaults: UserDefaults!
    private var storage: KeyValueStorage!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: suiteName)
        storage = KeyValueStorage(storage: userDefaults)
        storage.clearEventsCache()
    }
    
    override func tearDown() {
        storage.clearEventsCache()
        storage = nil
        userDefaults.removeSuite(named: suiteName)
        userDefaults = nil
        
        super.tearDown()
    }
    
    /// `addEvent` decodes the stored array, appends and encodes it back. Unsynchronized, two threads
    /// read the same array and the later write drops the event appended by the other one.
    func test_concurrentAddEvent_doesNotDropEvents() {
        let storage = self.storage!
        let eventsCount = 200
        
        DispatchQueue.concurrentPerform(iterations: eventsCount) { index in
            storage.addEvent(Event(eventTypeKey: "key_\(index)", date: Date(), parameters: []))
        }
        
        XCTAssertEqual(storage.getEvents().count, eventsCount, "every logged event should be persisted")
    }
    
    /// Reproduces the duplication path: `SendEventsOperation` clears a delivered batch on the main
    /// thread while the host app keeps calling `logEvent` from another one. An `addEvent` that read
    /// the array before the clear and wrote it back afterwards restores the delivered events, and the
    /// next batch sends them to the backend a second time.
    func test_addEventDuringClear_doesNotRestoreDeliveredEvents() {
        let storage = self.storage!
        let batchSize = 200
        let deliveredEvents = (0..<batchSize).map {
            Event(eventTypeKey: "delivered_\($0)", date: Date(), parameters: [])
        }
        deliveredEvents.forEach { storage.addEvent($0) }
        
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)
        
        queue.async(group: group) {
            storage.clearEvents(deliveredEvents)
        }
        for index in 0..<batchSize {
            queue.async(group: group) {
                storage.addEvent(Event(eventTypeKey: "logged_\(index)", date: Date(), parameters: []))
            }
        }
        group.wait()
        
        let storedIds = Set(storage.getEvents().map { $0.id })
        let deliveredIds = Set(deliveredEvents.map { $0.id })
        
        XCTAssertTrue(
            storedIds.isDisjoint(with: deliveredIds),
            "delivered events must not reappear in storage, they would be sent to the backend twice"
        )
        XCTAssertEqual(storedIds.count, batchSize, "events logged alongside the clear should be kept")
    }
    
}
