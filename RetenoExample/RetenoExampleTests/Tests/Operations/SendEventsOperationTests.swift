//
//  SendEventsOperationTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 22.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendEventsOperationTests: XCTestCase {
    
    private var operationQueue: OperationQueue!
    private var requestService: MobileRequestService!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        operationQueue = OperationQueue()
        requestService = MobileRequestService(requestManager: RequestManager.stub)
        userDefaults = UserDefaults(suiteName: "unit_tests_send_events_operation")
        storage = KeyValueStorage(storage: userDefaults)
        storage.clearEventsCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        operationQueue.cancelAllOperations()
        operationQueue = nil
        requestService = nil
        storage.clearEventsCache()
        userDefaults.removeSuite(named: "unit_tests_send_events_operation")
        HTTPStubs.removeAllStubs()
    }
    
    
    func test_sendEventsOperation_withEmptyEventBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = []
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getEvents().isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getEvents().isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withTenEventsInBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")]),
            Event(eventTypeKey: "key2", date: Date(), parameters: [.init(name: "name2", value: "value2")]),
            Event(eventTypeKey: "key3", date: Date(), parameters: [.init(name: "name3", value: "value3")]),
            Event(eventTypeKey: "key4", date: Date(), parameters: [.init(name: "name4", value: "value4")]),
            Event(eventTypeKey: "key5", date: Date(), parameters: [.init(name: "name5", value: "value5")]),
            Event(eventTypeKey: "key6", date: Date(), parameters: [.init(name: "name6", value: "value6")]),
            Event(eventTypeKey: "key7", date: Date(), parameters: [.init(name: "name7", value: "value7")]),
            Event(eventTypeKey: "key8", date: Date(), parameters: [.init(name: "name8", value: "value8")]),
            Event(eventTypeKey: "key9", date: Date(), parameters: [.init(name: "name9", value: "value9")]),
            Event(eventTypeKey: "key10", date: Date(), parameters: [.init(name: "name10", value: "value10")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getEvents().isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withTenEventsInBatchAndNegativeResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")]),
            Event(eventTypeKey: "key2", date: Date(), parameters: [.init(name: "name2", value: "value2")]),
            Event(eventTypeKey: "key3", date: Date(), parameters: [.init(name: "name3", value: "value3")]),
            Event(eventTypeKey: "key4", date: Date(), parameters: [.init(name: "name4", value: "value4")]),
            Event(eventTypeKey: "key5", date: Date(), parameters: [.init(name: "name5", value: "value5")]),
            Event(eventTypeKey: "key6", date: Date(), parameters: [.init(name: "name6", value: "value6")]),
            Event(eventTypeKey: "key7", date: Date(), parameters: [.init(name: "name7", value: "value7")]),
            Event(eventTypeKey: "key8", date: Date(), parameters: [.init(name: "name8", value: "value8")]),
            Event(eventTypeKey: "key9", date: Date(), parameters: [.init(name: "name9", value: "value9")]),
            Event(eventTypeKey: "key10", date: Date(), parameters: [.init(name: "name10", value: "value10")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getEvents() ?? []
            XCTAssertTrue(events.isNotEmpty, "array of events from storage shouldn't be empty")
            XCTAssertEqual(events.count, 10, "events.count should be equal to 10")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withTenEventsInBatchAndNegativeResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")]),
            Event(eventTypeKey: "key2", date: Date(), parameters: [.init(name: "name2", value: "value2")]),
            Event(eventTypeKey: "key3", date: Date(), parameters: [.init(name: "name3", value: "value3")]),
            Event(eventTypeKey: "key4", date: Date(), parameters: [.init(name: "name4", value: "value4")]),
            Event(eventTypeKey: "key5", date: Date(), parameters: [.init(name: "name5", value: "value5")]),
            Event(eventTypeKey: "key6", date: Date(), parameters: [.init(name: "name6", value: "value6")]),
            Event(eventTypeKey: "key7", date: Date(), parameters: [.init(name: "name7", value: "value7")]),
            Event(eventTypeKey: "key8", date: Date(), parameters: [.init(name: "name8", value: "value8")]),
            Event(eventTypeKey: "key9", date: Date(), parameters: [.init(name: "name9", value: "value9")]),
            Event(eventTypeKey: "key10", date: Date(), parameters: [.init(name: "name10", value: "value10")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getEvents() ?? []
            XCTAssertTrue(events.isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getEvents() ?? []
            XCTAssertTrue(events.isNotEmpty, "array of events from storage shouldn't be empty")
            XCTAssertEqual(events.count, 1, "events.count should be equal to 1")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [Event] = [
            Event(eventTypeKey: "key1", date: Date(), parameters: [.init(name: "name1", value: "value1")])
        ]
        for event in events {
            storage.addEvent(event)
        }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getEvents() ?? []
            XCTAssertTrue(events.isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    
    func test_sendEventsOperation_withEventsRemovedFromStorageBeforeStart_sendsOnlyStoredEvents() {
        let events = (1...3).map { Event(eventTypeKey: "key\($0)", date: Date(), parameters: []) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: events.map { $0.eventTypeKey })
        recorder.stubEventsRequest()
        events.forEach { storage.addEvent($0) }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        storage.clearEvents(Array(events.prefix(2)))
        
        let expectation = expectation(description: "Operation")
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(recorder.batches, [["key3"]], "only events remaining in storage should be sent")
        XCTAssertTrue(storage.getEvents().isEmpty, "array of events from storage should be empty")
    }
    
    func test_sendEventsOperation_withAllEventsRemovedFromStorageBeforeStart_doesNotSendRequest() {
        let events = (1...3).map { Event(eventTypeKey: "key\($0)", date: Date(), parameters: []) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: events.map { $0.eventTypeKey })
        recorder.stubEventsRequest()
        events.forEach { storage.addEvent($0) }
        
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        storage.clearEvents(events)
        
        let expectation = expectation(description: "Operation")
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 1.0)
        
        XCTAssertTrue(operation.isFinished, "operation should be finished")
        XCTAssertTrue(recorder.batches.isEmpty, "already delivered events shouldn't be sent again")
    }
    
    func test_sendEventsOperation_withEventsAboveBatchLimit_sendsSeveralRequests() {
        let events = (1...250).map { Event(eventTypeKey: "key\($0)", date: Date(), parameters: []) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: events.map { $0.eventTypeKey })
        recorder.stubEventsRequest()
        events.forEach { storage.addEvent($0) }
        
        let expectation = expectation(description: "Operation")
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0)
        
        XCTAssertEqual(recorder.batches.map { $0.count }, [100, 100, 50], "events should be split into batches")
        XCTAssertEqual(recorder.sentEventTypeKeys, events.map { $0.eventTypeKey }, "events should be sent in order")
        XCTAssertTrue(storage.getEvents().isEmpty, "array of events from storage should be empty")
    }
    
    func test_sendEventsOperation_withEventsAboveBatchLimitAndNegativeResult_with5xxStatusCode() {
        let events = (1...250).map { Event(eventTypeKey: "key\($0)", date: Date(), parameters: []) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: events.map { $0.eventTypeKey })
        recorder.stubEventsRequest(statusCode: 500)
        events.forEach { storage.addEvent($0) }
        
        let expectation = expectation(description: "Operation")
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0)
        
        XCTAssertEqual(recorder.batches.map { $0.count }, [100], "sending should stop after a failed batch")
        XCTAssertEqual(storage.getEvents().count, 250, "all events should be kept for retry")
    }
    
    func test_sendEventsOperation_withEventsAboveBatchLimitAndNegativeResult_with4xxStatusCode() {
        let events = (1...250).map { Event(eventTypeKey: "key\($0)", date: Date(), parameters: []) }
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: events.map { $0.eventTypeKey })
        recorder.stubEventsRequest(statusCode: 400)
        events.forEach { storage.addEvent($0) }
        
        let expectation = expectation(description: "Operation")
        let operation = SendEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = {
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 3.0)
        
        XCTAssertEqual(recorder.batches.map { $0.count }, [100, 100, 50], "rejected batch shouldn't stop next batches")
        XCTAssertTrue(storage.getEvents().isEmpty, "array of events from storage should be empty")
    }
    
    
    func test_sendEventsOperation_cancelledWhileRequestInFlight_clearsDeliveredEvents() {
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["key1"])
        recorder.stubEventsRequest(responseTime: 1.0)
        let event = Event(eventTypeKey: "key1", date: Date(), parameters: [])
        storage.addEvent(event)
        
        operationQueue.addOperation(SendEventsOperation(requestService: requestService, storage: storage, events: [event]))
        let operationQueue = self.operationQueue!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            operationQueue.cancelAllOperations()
        }
        wait(seconds: 2.0)
        
        XCTAssertEqual(recorder.sentEventTypeKeys, ["key1"], "event should be sent once")
        XCTAssertTrue(storage.getEvents().isEmpty, "events accepted by the backend should be removed from storage")
        XCTAssertEqual(operationQueue.operationCount, 0, "operation should be finished after the response")
    }
    
    func test_sendEventsOperation_cancelledBeforeStart_finishesWithoutSending() {
        let recorder = EventsRequestsRecorder(trackedEventTypeKeys: ["key1"])
        recorder.stubEventsRequest(responseTime: 1.0)
        let event = Event(eventTypeKey: "key1", date: Date(), parameters: [])
        storage.addEvent(event)
        
        let operationQueue = self.operationQueue!
        operationQueue.maxConcurrentOperationCount = 1
        let firstOperation = SendEventsOperation(requestService: requestService, storage: storage, events: [event])
        let secondOperation = SendEventsOperation(requestService: requestService, storage: storage, events: [event])
        secondOperation.addDependency(firstOperation)
        operationQueue.addOperations([firstOperation, secondOperation], waitUntilFinished: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            operationQueue.cancelAllOperations()
        }
        wait(seconds: 2.0)
        
        XCTAssertTrue(secondOperation.isFinished, "cancelled operation should be finished")
        XCTAssertEqual(operationQueue.operationCount, 0, "cancelled operations shouldn't block the queue")
        XCTAssertEqual(recorder.sentEventTypeKeys, ["key1"], "cancelled operation shouldn't send events")
        XCTAssertTrue(storage.getEvents().isEmpty, "events accepted by the backend should be removed from storage")
    }
    
    
    private func wait(seconds: TimeInterval) {
        let expectation = expectation(description: "Wait for \(seconds) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1.0)
    }
    
}
