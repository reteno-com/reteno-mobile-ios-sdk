//
//  SendingServicesTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 26.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class SendingServicesTests: XCTestCase {

    private var sut: SendingServices!
    
    override func setUp() {
        sut = SendingServices(requestManager: RequestManager.stub)
    }
    
    override func tearDown() {
        sut = nil
        HTTPStubs.removeAllStubs()
    }
    
    func test_updateInteractionStatusRequest() throws {
        stub(condition: pathEndsWith("v1/interactions/-1/status")) { _ in
          let stubData = "OK".data(using: .utf8)
              
          return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.updateInteractionStatus(
            status: NotificationStatus(interactionId: "-1", status: .delivered, date: Date()),
            token: "token"
        ) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess == true, "should return true")
        }
    }
    
    func test_registerLinkClickRequest() throws {
        let link = StorableLink(value: "google.com", date: Date())
        stub(condition: pathEndsWith(link.value)) { _ in
          let stubData = "OK".data(using: .utf8)
              
          return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.registerLinkClick(link.value) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess == true, "should return true")
        }
    }

}
