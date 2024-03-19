//
//  InAppServiceTests.swift
//  RetenoExampleTests
//
//  Created by Oleh Mytsovda on 31.01.2024.
//  Copyright © 2024 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class InAppServiceTests: XCTestCase {
    
    private var userDefaults: UserDefaults!
    private var storage: KeyValueStorage!
    private var sut: InAppService!
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests_operations")
        storage = KeyValueStorage(storage: userDefaults)
        sut = .init(
            requestService: MobileRequestService(requestManager: RequestManager.stub),
            storage: KeyValueStorage(storage: UserDefaults(suiteName: "unit_tests_operations"))
        )
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        sut = nil
        clearStorage()
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }

    private func clearStorage() {
        userDefaults.removeObject(forKey: StorageKeys.users.rawValue)
    }
    
    func test_getInAppMessages() {
        let eTag = "1234567890"
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: ["ETag": eTag])
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubPath = OHPathForFile("in_app_message_content.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var receivedContents: [InAppContent] = []
        var receivedShowModels: [InAppShowModel] = []
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            receivedContents = contents
            receivedShowModels = showModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertTrue(receivedContents.isNotEmpty, "contenst shouldn't be empty")
            XCTAssertTrue(receivedShowModels.isNotEmpty, "models shouldn't be empty")
            XCTAssertTrue(receivedContents.count == receivedShowModels.count, "count of values should be equel")
            XCTAssertTrue(eTag == self.storage.getValue(forKey: StorageKeys.eTag.rawValue), "eTag shoud be equal")
        }
    }
    
    func test_getInAppMessagesWithNotFailedResult() {
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var noData = true
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            noData = false
        }
        
        expectation.fulfill()
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(noData, "data shoudn't be collected")
        }
    }
    
    
    func test_getInAppMessagesFiltering() {
        let eTag = "1234567890"
        storage.addOnlyOnceDisplayedId(id: 123123123)
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages_valid.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: ["ETag": eTag])
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubPath = OHPathForFile("in_app_contents_valid.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var receivedContents: [InAppContent] = []
        var receivedShowModels: [InAppShowModel] = []
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            receivedContents = contents
            receivedShowModels = showModels
            expectation.fulfill()
        }
        
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertTrue(receivedShowModels.count == 1)
            XCTAssertTrue(receivedContents.count == 1)
            XCTAssertTrue(receivedShowModels.count == receivedContents.count, "should be same count of elements")
            XCTAssertTrue(eTag == self.storage.getValue(forKey: StorageKeys.eTag.rawValue), "eTag shoud be equal")
        }
    }
}
