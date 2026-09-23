//
//  EventsSenderSchedulerTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 18.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class EventsSenderSchedulerTests: XCTestCase {
    
    private var sut: EventsSenderScheduler!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests")
        storage = KeyValueStorage(storage: userDefaults)
        sut = EventsSenderScheduler(
            mobileRequestService: MobileRequestServiceBuilder.build(),
            storage: storage,
            sendingService: SendingServiceBuilder.build()
        )
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        userDefaults.removeSuite(named: "unit_tests")
        sut = nil
        HTTPStubs.removeAllStubs()
    }

    func test_updatingNotificationInteractionStatus_withFailedRequest() {
        let expectation = expectation(description: "UserDefaults changed")
        expectation.assertForOverFulfill = false
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        let interactionId = "-1"
        let eventDate = Date()
        stub(condition: pathEndsWith("v1/interactions/\(interactionId)/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        sut.updateNotificationInteractionStatus(interactionId: interactionId, status: .delivered, date: eventDate)
        wait(for: [expectation], timeout: 10.0)
        
        let savedNotification = storage.getNotificationStatuses().first(where: { $0.interactionId == interactionId && $0.date == eventDate })
        XCTAssertTrue(savedNotification.isSome, "status should be stored")
    }
    
    func test_updatingUserAttributes_withFailedRequest() {
        let expectation = expectation(description: "UserDefaults changed")
        expectation.assertForOverFulfill = false
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        sut.updateUserAttributes(
            externalUserId: nil,
            userAttributes: UserAttributes(phone: "0509876543", email: "test@gmail.com", firstName: "John"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: [],
            isAnonymous: false
        )
        wait(for: [expectation], timeout: 1.0)
        
        let savedUser = storage.getUsers().first(where: {
            $0.userAttributes?.phone == "0509876543" && $0.userAttributes?.email == "test@gmail.com" && $0.userAttributes?.firstName == "John"
        })
        XCTAssertTrue(savedUser.isSome, "userAttributes should be stored")
    }
    
    
    func test_forcePushEvents_whileSyncInProgress_doesNotResendEvents() {
        prepareInitializedSDK()
        defer { Reteno.sdkStateHelper.set(isInitialized: false) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["overlap_key"])
        recorder.stubEventsRequest(responseTime: 2.0)
        storage.addEvent(Event(eventTypeKey: "overlap_key", date: Date().addingTimeInterval(-1), parameters: []))
        
        let sut = self.sut!
        sut.forcePushEvents()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            sut.forcePushEvents()
        }
        wait(seconds: 3.5)
        
        XCTAssertEqual(recorder.sentEventTypeKeys, ["overlap_key"], "event should be sent once")
        XCTAssertTrue(storage.getEvents().isEmpty, "sent events should be removed from storage")
    }
    
    func test_concurrentForcePushEvents_sendEventsOnce() {
        prepareInitializedSDK()
        defer { Reteno.sdkStateHelper.set(isInitialized: false) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["concurrent_key"])
        recorder.stubEventsRequest(responseTime: 0.3)
        storage.addEvent(Event(eventTypeKey: "concurrent_key", date: Date().addingTimeInterval(-1), parameters: []))
        
        let sut = self.sut!
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            sut.forcePushEvents()
        }
        wait(seconds: 2.0)
        
        XCTAssertEqual(recorder.sentEventTypeKeys, ["concurrent_key"], "event should be sent once")
        XCTAssertTrue(storage.getEvents().isEmpty, "sent events should be removed from storage")
    }
    
    func test_forcePushEvents_whileSyncInProgress_sendsNewEventsInFollowUpSync() {
        prepareInitializedSDK()
        defer { Reteno.sdkStateHelper.set(isInitialized: false) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["first_key", "second_key"])
        recorder.stubEventsRequest(responseTime: 1.0)
        storage.addEvent(Event(eventTypeKey: "first_key", date: Date().addingTimeInterval(-1), parameters: []))
        
        let sut = self.sut!
        let storage = self.storage!
        sut.forcePushEvents()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            storage.addEvent(Event(eventTypeKey: "second_key", date: Date(), parameters: []))
            sut.forcePushEvents()
        }
        wait(seconds: 3.5)
        
        XCTAssertEqual(recorder.batches, [["first_key"], ["second_key"]], "event logged during sync should be sent by the follow-up sync")
        XCTAssertTrue(storage.getEvents().isEmpty, "sent events should be removed from storage")
    }
    
    func test_scheduledSync_beforeInitialization_doesNotBlockLaterSyncs() {
        storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
        Reteno.sdkStateHelper.set(isInitialized: false)
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["scheduled_key"])
        recorder.stubEventsRequest()
        let scheduler = EventsSenderScheduler(
            mobileRequestService: MobileRequestServiceBuilder.build(),
            storage: storage,
            sendingService: SendingServiceBuilder.build(),
            timeIntervalResolver: { 0.2 },
            randomOffsetResolver: { 0 }
        )
        scheduler.scheduleTask()
        wait(seconds: 0.7)
        
        Reteno.sdkStateHelper.set(isInitialized: true)
        defer { Reteno.sdkStateHelper.set(isInitialized: false) }
        storage.addEvent(Event(eventTypeKey: "scheduled_key", date: Date().addingTimeInterval(-1), parameters: []))
        wait(seconds: 1.0)
        
        XCTAssertEqual(recorder.sentEventTypeKeys, ["scheduled_key"], "scheduled sync should send events once SDK is initialized")
        withExtendedLifetime(scheduler) {}
    }
    
    
    private func prepareInitializedSDK() {
        Reteno.sdkStateHelper.set(isInitialized: true)
        storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
    }
    
    private func wait(seconds: TimeInterval) {
        let expectation = expectation(description: "Wait for \(seconds) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1.0)
    }

    func test_twoFlushesBeforeAcknowledgement_reproduceDuplicateEventSnapshot() {
        let wasInitialized = Reteno.sdkStateHelper.isInitialized
        Reteno.sdkStateHelper.set(isInitialized: true)
        defer { Reteno.sdkStateHelper.set(isInitialized: wasInitialized) }

        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
        sut = EventsSenderScheduler(
            mobileRequestService: MobileRequestService(requestManager: .stub),
            storage: storage
        )

        let firstRequest = expectation(description: "First batch started")
        let secondRequest = expectation(description: "Second batch started")
        let lock = NSLock()
        var payloads: [[String]] = []
        stub(condition: isHost("test.host") && pathEndsWith("v1/events")) { [storage] request in
            let body = request.ohhttpStubs_httpBody ?? Data()
            let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
            let events = json?["events"] as? [[String: Any]] ?? []
            let keys = events.compactMap { $0["eventTypeKey"] as? String }
            lock.lock()
            payloads.append(keys)
            let requestNumber = payloads.count
            lock.unlock()

            if requestNumber == 1 {
                firstRequest.fulfill()
            } else if requestNumber == 2 {
                XCTAssertEqual(storage?.getEvents().map { $0.eventTypeKey }, ["probe_B"])
                secondRequest.fulfill()
            } else {
                XCTFail("Unexpected additional request")
            }
            let response = HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
            response.responseTime = requestNumber == 1 ? 3.0 : 0
            return response
        }

        storage.addEvent(Event(eventTypeKey: "probe_A", date: Date(), parameters: []))
        sut.forcePushEvents()
        wait(for: [firstRequest], timeout: 5)

        // Main-queue callbacks cannot acknowledge A while we wait out the force-push throttle.
        XCTAssertTrue(Thread.isMainThread)
        Thread.sleep(forTimeInterval: 1.2)
        storage.addEvent(Event(eventTypeKey: "probe_B", date: Date(), parameters: []))
        sut.forcePushEvents()
        wait(for: [secondRequest], timeout: 10)

        let drained = XCTNSPredicateExpectation(
            predicate: NSPredicate { [storage] _, _ in storage?.getEvents().isEmpty == true },
            object: nil
        )
        wait(for: [drained], timeout: 5)
        lock.lock()
        let capturedPayloads = payloads
        lock.unlock()
        XCTAssertEqual(capturedPayloads, [["probe_A"], ["probe_B"]])
    }

}
