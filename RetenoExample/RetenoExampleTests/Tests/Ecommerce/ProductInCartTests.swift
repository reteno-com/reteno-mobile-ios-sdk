//
//  ProductInCartTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 11.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ProductInCartTests: XCTestCase {

    private var sut: Ecommerce.ProductInCart!
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_convertToJSON() {
        sut = Ecommerce.ProductInCart(
            productId: "ugjg",
            price: 20.0,
            quantity: 40,
            name: "name",
            category: "summer",
            attributes: ["color": ["yellow", "red"]]
        )
        let result = sut.toJSON()
        XCTAssertEqual(result["productId"] as? String, "ugjg", "should contains valid productId parameter")
        XCTAssertEqual(result["price"] as? Float, 20.0, "should contains valid price parameter")
        XCTAssertEqual(result["quantity"] as? Int, 40, "should contains valid quantity parameter")
        XCTAssertEqual(result["name"] as? String, "name", "should contains valid name parameter")
        XCTAssertEqual(result["category"] as? String, "summer", "should contains valid category parameter")
        XCTAssertEqual(result["color"] as? [String], ["yellow", "red"], "should contains valid color parameter")
    }

}
