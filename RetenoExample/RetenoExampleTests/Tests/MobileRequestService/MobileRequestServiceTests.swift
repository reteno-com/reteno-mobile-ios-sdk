//
//  MobileRequestServiceTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 04.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class MobileRequestServiceTests: XCTestCase {
    
    private var sut: MobileRequestService!
    
    override func setUp() {
        sut = MobileRequestService(requestManager: RequestManager.stub)
    }
    
    override func tearDown() {
        sut = nil
        HTTPStubs.removeAllStubs()
    }
    
    // MARK: Upsert device
    
    func test_upsertDeviceRequest_withPositiveResult() throws {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.upsertDevice(isSubscribedOnPush: true) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_upsertDeviceRequest_withNegativeResult() throws {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.upsertDevice(isSubscribedOnPush: true) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Log events
    
    func test_logEventsRequest_withPositiveResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendEvents([Event(eventTypeKey: "event_key", date: Date(), parameters: [.init(name: "param_name", value: "param_value")])]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_logEventsRequest_withNegativeResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendEvents([Event(eventTypeKey: "event_key", date: Date(), parameters: [.init(name: "param_name", value: "param_value")])]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Get inbox messages
    
    func test_getInboxMessages_withPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages")) { _ in
            let stubData = "{\"list\":[], \"totalPages\":3}".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        var expectedResponse: AppInboxMessagesResponse?
        let expectation = expectation(description: "Request")
        sut.getInboxMessages(page: nil, pageSize: nil) { result in
            switch result {
            case .success(let response):
                expectedSuccess = true
                expectedResponse = response
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
            XCTAssertEqual(expectedResponse?.totalPages, 3, "expected response totalPages should be 3")
        }
    }
    
    func test_getInboxMessages_withNegativeResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.getInboxMessages(page: nil, pageSize: nil) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Mark inbox message as opened
    
    func test_markInboxMessagesAsOpened_withPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened(ids: []) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_markInboxMessagesAsOpened_withNegativeResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened(ids: []) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
}
