//
//  ProductTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 11.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ProductTests: XCTestCase {

    private var sut: Ecommerce.Product!
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_convertToString() {
        sut = Ecommerce.Product(
            productId: "jfhfh",
            price: 20,
            isInStock: true,
            attributes: ["size": ["M", "S"]]
        )
        let result = sut.convertToString()
        XCTAssertTrue(result?.contains("\"productId\":\"jfhfh\"") == true, "should contains valid productId")
        XCTAssertTrue(result?.contains("\"price\":20") == true, "should contains valid price")
        XCTAssertTrue(result?.contains("\"isInStock\":1") == true, "should contains valid isInStock")
        XCTAssertTrue(result?.contains("\"size\":[\"M\",\"S\"]") == true, "should contains valid size")
    }

}
