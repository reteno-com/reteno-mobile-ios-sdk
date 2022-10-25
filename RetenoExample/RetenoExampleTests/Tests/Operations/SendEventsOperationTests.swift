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
        userDefaults = UserDefaults(suiteName: "unit_tests_operations")
        storage = KeyValueStorage(storage: userDefaults)
        storage.clearEventsCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        operationQueue.cancelAllOperations()
        operationQueue = nil
        requestService = nil
        storage.clearEventsCache()
        userDefaults.removeSuite(named: "unit_tests_operations")
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
    
    func test_sendEventsOperation_withTenEventsInBatchAndNegativeResult() {
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
            XCTAssertTrue(events.isNotEmpty, "array of events from storage shouldn't be empty")
            XCTAssertEqual(events.count, 10, "events.count should be equal to 10")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult() {
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
            XCTAssertTrue(events.isNotEmpty, "array of events from storage shouldn't be empty")
            XCTAssertEqual(events.count, 1, "events.count should be equal to 1")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
}
