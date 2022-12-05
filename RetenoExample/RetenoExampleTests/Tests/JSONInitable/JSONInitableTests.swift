//
//  JSONInitableTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 10.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class JSONInitableTests: XCTestCase {
    
    struct Product: Decodable {
        
        let name: String
        let description: String
        let price: Float
        let count: Int
        
    }
    
    struct Recommendation: Decodable, JSONInitable {
        
        let productId: String
        let products: [Product]
        
    }

    func test_initializationFromJSON() throws {
        let json: [String: Any] = [
            "productId": "identificator",
            "products": [
                [
                    "name": "Apple",
                    "description": "Some text",
                    "price": 20.0,
                    "count": 5
                ],
                [
                    "name": "Potato",
                    "description": "Some text",
                    "price": 16.0,
                    "count": 50
                ]
            ]
        ]
        let result = try XCTUnwrap(try Recommendation(json: json), "shouldn't be nil")
        
        XCTAssertEqual(result.productId, "identificator", "should have valid `productId`")
        XCTAssertEqual(result.products.count, 2, "should have 2 products")
        XCTAssertEqual(result.products[0].name, "Apple", "should have valid `name`")
        XCTAssertEqual(result.products[0].description, "Some text", "should have valid `description`")
        XCTAssertEqual(result.products[0].price, 20.0, "should have valid `price`")
        XCTAssertEqual(result.products[0].count, 5, "should have valid `count`")
        XCTAssertEqual(result.products[1].name, "Potato", "should have valid `name`")
        XCTAssertEqual(result.products[1].description, "Some text", "should have valid `description`")
        XCTAssertEqual(result.products[1].price, 16.0, "should have valid `price`")
        XCTAssertEqual(result.products[1].count, 50, "should have valid `count`")
    }

}
