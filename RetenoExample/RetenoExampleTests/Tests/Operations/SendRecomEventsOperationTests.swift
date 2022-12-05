//
//  SendRecomEventsOperationTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 15.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendRecomEventsOperationTests: XCTestCase {

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
        storage.clearRecomEventsCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        operationQueue.cancelAllOperations()
        operationQueue = nil
        requestService = nil
        storage.clearRecomEventsCache()
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }
    
    func test_sendEventsOperation_withEmptyBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [RecomEvents] = []
        for event in events {
            storage.addRecomEvent(event)
        }
        
        let operation = SendRecomEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getRecomEvents().isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [RecomEvents] = [
            RecomEvents(recomVariantId: "edkt99", impressions: [], clicks: [])
        ]
        for event in events {
            storage.addRecomEvent(event)
        }
        
        let operation = SendRecomEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getRecomEvents().isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [RecomEvents] = [
            RecomEvents(recomVariantId: "edkt99", impressions: [], clicks: [])
        ]
        for event in events {
            storage.addRecomEvent(event)
        }
        
        let operation = SendRecomEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getRecomEvents() ?? []
            XCTAssertTrue(events.isEmpty, "array of events from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let events: [RecomEvents] = [
            RecomEvents(recomVariantId: "edkt99", impressions: [], clicks: [])
        ]
        for event in events {
            storage.addRecomEvent(event)
        }
        
        let operation = SendRecomEventsOperation(requestService: requestService, storage: storage, events: events)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let events = storage?.getRecomEvents() ?? []
            XCTAssertTrue(events.isNotEmpty, "array of events from storage shouldn't be empty")
            XCTAssertEqual(events.count, 1, "events.count should be equal to 1")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }

}
