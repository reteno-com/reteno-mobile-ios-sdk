//
//  SendUserOperationTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 21.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendUserOperationTests: XCTestCase {
    
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
    }
    
    override func tearDown() {
        super.tearDown()
        
        operationQueue.cancelAllOperations()
        operationQueue = nil
        requestService = nil
        clearStorage()
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }
    
    private func clearStorage() {
        userDefaults.removeObject(forKey: StorageKeys.users.rawValue)
    }
    
    func test_sendUserOperation_withExternalUserIdAndPositiveResult() {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            externalUserId: "kldsakldsaklas",
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getUsers().isEmpty, "array of users from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendUserOperation_withoutExternalUserIdAndPositiveResult() {
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isFinished, "operation should be finished")
            XCTAssertTrue(storage!.getUsers().isEmpty, "array of users from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendUserOperation_withExternalUserIdAndFailedDeviceResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            externalUserId: "kldsakldsaklas",
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isCancelled, "operation should be canceled")
            XCTAssertTrue(storage!.getUsers().isNotEmpty, "array of users from storage shouldn't be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendUserOperation_withExternalUserIdAndFailedDeviceResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            externalUserId: "kldsakldsaklas",
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isCancelled, "operation should be canceled")
            XCTAssertTrue(storage!.getUsers().isEmpty, "array of users from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendUserOperation_withExternalUserIdAndFailedUserResult_with5xxStatusCode() {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 500, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            externalUserId: "kldsakldsaklas",
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isCancelled, "operation should be canceled")
            XCTAssertTrue(storage!.getUsers().isNotEmpty, "array of users from storage shouldn't be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_sendUserOperation_withExternalUserIdAndFailedUserResult_with4xxStatusCode() {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        let expectation = expectation(description: "Operation")
        let user = User(
            externalUserId: "kldsakldsaklas",
            userAttributes: UserAttributes(
                phone: "999999",
                email: "sssss.test@gmail.com",
                firstName: "first",
                lastName: "last",
                fields: [UserCustomField(key: "key1", value: "value1")]
            ),
            subscriptionKeys: ["key2, key3"],
            groupNamesInclude: ["group1"],
            groupNamesExclude: ["group2"],
            date: Date()
        )
        storage.addUser(user)
        let operation = SendUserOperation(
            requestService: requestService,
            storage: storage,
            user: user
        )
        
        operation.completionBlock = { [unowned storage] in
            XCTAssertTrue(operation.isCancelled, "operation should be canceled")
            XCTAssertTrue(storage!.getUsers().isEmpty, "array of users from storage should be empty")
            
            expectation.fulfill()
        }
        operationQueue.addOperation(operation)
        
        waitForExpectations(timeout: 1.0)
    }
    
}
