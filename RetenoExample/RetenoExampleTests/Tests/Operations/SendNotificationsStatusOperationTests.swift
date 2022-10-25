//
//  SendNotificationsStatusOperationTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 22.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendNotificationsStatusOperationTests: XCTestCase {
    
    private var operationQueue: OperationQueue!
    private var sendingService: SendingServices!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        operationQueue = OperationQueue()
        sendingService = SendingServices(requestManager: RequestManager.stub)
        userDefaults = UserDefaults(suiteName: "unit_tests_operations")
        storage = KeyValueStorage(storage: userDefaults)
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        
        clearStorage()
        operationQueue.cancelAllOperations()
        operationQueue = nil
        sendingService = nil
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }
    
    private func clearStorage() {
        userDefaults.removeObject(forKey: StorageKeys.notificationStatuses.rawValue)
    }
    
    func test_sendNotificationsStatusOperation_withPositiveResult() {
        let interactionId = "klsdalksdnvksndjksd"
        stub(condition: pathEndsWith("v1/interactions/\(interactionId)/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let notificationStatus = NotificationStatus(interactionId: interactionId, status: .delivered, date: Date())
        storage.addNotificationStatus(notificationStatus)
        
        let operation = SendNotificationsStatusOperation(
            sendingService: sendingService,
            storage: storage,
            notificationStatus: notificationStatus
        )
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getNotificationStatuses().isEmpty, "array of notification statuses from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendNotificationsStatusOperation_withNegativeResult() {
        let interactionId = "klsdalksdnvksndjksd"
        stub(condition: pathEndsWith("v1/interactions/\(interactionId)/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let notificationStatus = NotificationStatus(interactionId: interactionId, status: .delivered, date: Date())
        storage.addNotificationStatus(notificationStatus)
        
        let operation = SendNotificationsStatusOperation(
            sendingService: sendingService,
            storage: storage,
            notificationStatus: notificationStatus
        )
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getNotificationStatuses().isNotEmpty, "array of notification statuses from storage shouldn't be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
}
