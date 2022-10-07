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
    
    func test_upsertDeviceRequest_withPositiveResult() throws {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.upsertDevice { result in
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
        sut.upsertDevice { result in
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
