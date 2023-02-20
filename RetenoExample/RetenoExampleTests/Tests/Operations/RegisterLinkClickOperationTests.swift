//
//  RegisterLinkClickOperationTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 09.02.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class RegisterLinkClickOperationTests: XCTestCase {

    private var operationQueue: OperationQueue!
    private var sendingService: SendingServices!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        operationQueue = OperationQueue()
        sendingService = SendingServiceBuilder.buildServiceWithEmptyURL()
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
        userDefaults.removeObject(forKey: StorageKeys.wrappedLinks.rawValue)
    }
    
    func test_registerLinkClickedOperation_withPositiveResult() {
        let link = StorableLink(value: "google.com", date: Date())
        stub(condition: pathEndsWith(link.value)) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        storage.appendLink(link)
        
        let operation = RegisterLinkClickOperation(requestService: sendingService, storage: storage, link: link)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getLinks().isEmpty, "array of links from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_registerLinkClickedOperation_withNegativeResult_and4xxStatusCode() {
        let link = StorableLink(value: "google.com", date: Date())
        stub(condition: pathEndsWith(link.value)) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        storage.appendLink(link)
        
        let operation = RegisterLinkClickOperation(requestService: sendingService, storage: storage, link: link)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getLinks().isEmpty, "array of notification statuses from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_registerLinkClickedOperation_withNegativeResult_and5xxStatusCode() {
        let link = StorableLink(value: "google.com", date: Date())
        stub(condition: pathEndsWith(link.value)) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        storage.appendLink(link)
        
        let operation = RegisterLinkClickOperation(requestService: sendingService, storage: storage, link: link)
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getLinks().isNotEmpty, "array of notification statuses from storage shouldn't be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }

}
