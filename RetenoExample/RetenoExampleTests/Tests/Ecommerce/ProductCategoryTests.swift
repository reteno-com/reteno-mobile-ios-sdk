//
//  ProductCategoryTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 11.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ProductCategoryTests: XCTestCase {

    private var sut: Ecommerce.ProductCategory!
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_convertToString() {
        sut = Ecommerce.ProductCategory(
            productCategoryId: "ugug",
            attributes: ["size": ["M", "L"]]
        )
        let result = sut.convertToString()
        XCTAssertTrue(result?.contains("\"productCategoryId\":\"ugug\"") == true, "should contains valid productCategoryId")
        XCTAssertTrue(result?.contains("\"size\":[\"M\",\"L\"]") == true, "should contains valid size")
    }
    
    func test_convertToStringWithoutAttributes() {
        sut = Ecommerce.ProductCategory(
            productCategoryId: "123"
        )
        XCTAssertEqual(sut.attributes, nil,  "doesn't contain attributes")
    }

}
