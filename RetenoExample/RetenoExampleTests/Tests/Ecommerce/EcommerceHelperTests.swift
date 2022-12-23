//
//  EcommerceHelperTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 09.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class EcommerceHelperTests: XCTestCase {

    private var sut: EcommerceHelper!
    
    override func setUp() {
        super.setUp()
        
        sut = EcommerceHelper()
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_convertJSON_dictionary_toString() {
        let json: [String: Any] = [
            "id": "jgjg8",
            "price": 30.0,
            "isInStock": false
        ]
        let result = sut.convertJSONToString(json)
        XCTAssertTrue(result?.contains("\"id\":\"jgjg8\"") == true, "result should contains id with valid value")
        XCTAssertTrue(result?.contains("\"price\":30") == true, "result should contains price with valid value")
        XCTAssertTrue(result?.contains("\"isInStock\":false") == true, "result should contains isInStock with valid value")
    }
    
    func test_convertJSON_array_toString() {
        let json: [String: Any] = [
            "id": "jgjg8",
            "price": 30.0,
            "isInStock": false
        ]
        let result = sut.convertJSONToString([json])
        XCTAssertTrue(result?.contains("\"id\":\"jgjg8\"") == true, "result should contains id with valid value")
        XCTAssertTrue(result?.contains("\"price\":30") == true, "result should contains price with valid value")
        XCTAssertTrue(result?.contains("\"isInStock\":false") == true, "result should contains isInStock with valid value")
    }

}
