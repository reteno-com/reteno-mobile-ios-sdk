//
//  SendAppInboxMessagesIdsOperationTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendAppInboxMessagesIdsOperationTests: XCTestCase {

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
        storage.clearInboxOpenedMessagesIdsCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        operationQueue.cancelAllOperations()
        operationQueue = nil
        requestService = nil
        storage.clearInboxOpenedMessagesIdsCache()
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }
    
    func test_sendIdsOperation_withEmptyBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let ids: [AppInboxMessageStorableId] = []
        storage.addInboxOpenedMessagesIds(ids)
        
        let operation = SendAppInboxMessagesIdsOperation(requestService: requestService, storage: storage, ids: ids)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getInboxOpenedMessagesIds().isEmpty, "array of ids from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendIdsOperation_withOneIdInBatchAndPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let ids: [AppInboxMessageStorableId] = [
            AppInboxMessageStorableId(id: "23", date: Date())
        ]
        storage.addInboxOpenedMessagesIds(ids)
        
        let operation = SendAppInboxMessagesIdsOperation(requestService: requestService, storage: storage, ids: ids)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getInboxOpenedMessagesIds().isEmpty, "array of ids from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendIdsOperation_withOneIdInBatchAndNegativeResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let ids: [AppInboxMessageStorableId] = [
            AppInboxMessageStorableId(id: "23", date: Date())
        ]
        storage.addInboxOpenedMessagesIds(ids)
        
        let operation = SendAppInboxMessagesIdsOperation(requestService: requestService, storage: storage, ids: ids)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let ids = storage?.getInboxOpenedMessagesIds() ?? []
            XCTAssertTrue(ids.isEmpty, "array of ids from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendEventsOperation_withOneEventInBatchAndNegativeResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let ids: [AppInboxMessageStorableId] = [
            AppInboxMessageStorableId(id: "23", date: Date())
        ]
        storage.addInboxOpenedMessagesIds(ids)
        
        let operation = SendAppInboxMessagesIdsOperation(requestService: requestService, storage: storage, ids: ids)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            let ids = storage?.getInboxOpenedMessagesIds() ?? []
            XCTAssertTrue(ids.isNotEmpty, "array of ids from storage shouldn't be empty")
            XCTAssertEqual(ids.count, 1, "ids.count should be equal to 1")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }

}
