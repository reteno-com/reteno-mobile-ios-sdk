//
//  InAppRequestServiceTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 31.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class InAppRequestServiceTests: XCTestCase {

    private var sut: InAppRequestService!
    
    override func setUp() {
        sut = InAppRequestService(requestManager: .stub)
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        sut = nil
    }
    
    // MARK: Fetch base HTML
    
    func test_fetchBaseHTML_withValidHeaders() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: ["x-amz-meta-version": "20230125-1501-b1c69b2"])
        }
        var expectedHeader: String?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
            switch result {
            case .success(let version):
                expectedHeader = version
                
            case .failure:
                expectedHeader = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(expectedHeader, "20230125-1501-b1c69b2", "should return valid expected version in header")
        }
    }
    
    func test_fetchBaseHTML_withEmptyHeaders() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedHeader: String?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
            switch result {
            case .success(let version):
                expectedHeader = version
                
            case .failure:
                expectedHeader = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNil(expectedHeader, "version from headers should be nil")
        }
    }
    
    func test_fetchBaseHTML_withNegativeResult() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
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
    
    // MARK: Send script event
    
    func test_sendScriptEvent_withPositiveResult() {
        stub(condition: pathEndsWith("site-script/v1/event")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendScriptEvent(messageId: "id", data: [:]) { result in
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
    
    func test_sendScriptEvent_withNegativeResult() {
        stub(condition: pathEndsWith("site-script/v1/event")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendScriptEvent(messageId: "id", data: [:]) { result in
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
