//
//  DeepLinksProcessorTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 09.02.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class DeepLinksProcessorTests: XCTestCase {
    
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests")
        storage = KeyValueStorage(storage: userDefaults)
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        userDefaults.removeSuite(named: "unit_tests")
        HTTPStubs.removeAllStubs()
    }

    func test_processLinks_withSuccessRequest() {
        let rawURL = URL(string: "google.com")
        let url = URL(string: "wrapped.google.com")
        let expectation = expectation(description: "UserDefaults changed")
        expectation.assertForOverFulfill = false
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        stub(condition: pathEndsWith(url?.absoluteString ?? "")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        DeepLinksProcessor.processLinks(wrappedUrl: url, rawURL: rawURL, isInAppMessageLink: true, storage: storage)
        wait(for: [expectation], timeout: 1.0)
        
        let result = storage.getLinks().first(where: { $0.value == url?.absoluteString })
        XCTAssertNotNil(result, "should be value in storage")
    }

}
