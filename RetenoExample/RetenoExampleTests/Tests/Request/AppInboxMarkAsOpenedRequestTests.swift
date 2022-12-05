//
//  AppInboxMarkAsOpenedRequestTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 21.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class AppInboxMarkAsOpenedRequestTests: XCTestCase {

    private var sut: AppInboxMarkAsOpenedRequest!
    
    override func tearDown() {
        sut = nil
    }
    
    func test_markMessagesAsOpenedRequest_hasValidParameters() {
        sut = AppInboxMarkAsOpenedRequest(ids: ["utut", "kriru"])
        let result = sut.parameters
        
        XCTAssertNotNil(result?["ids"], "parameter `ids` shouldn't be nil")
    }
    
    func test_markAllMessagesAsOpenedRequest_hasValidParameters() {
        sut = AppInboxMarkAsOpenedRequest(ids: nil)
        let result = sut.parameters
        
        XCTAssertNil(result?["ids"], "parameter `ids` should be nil")
    }

}
