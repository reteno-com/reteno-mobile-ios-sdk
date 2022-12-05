//
//  RecomsResponseHandlerTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 10.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class RecomsResponseHandlerTests: XCTestCase {
    
    struct Product: Decodable {
        
        let name: String
        let description: String
        let price: Float
        let count: Int
        
    }
    
    struct Recommendation: Decodable, RecommendableProduct {
        
        let productId: String
        let products: [Product]
        
    }
    
    private var sut: RecomsResponseHandler<Recommendation>!
    
    override func setUp() {
        sut = RecomsResponseHandler<Recommendation>()
    }
    
    override func tearDown() {
        sut = nil
    }

    func test_responseHandling() throws {
        let responseData = try XCTUnwrap(validJsonData(), "shouldn't be nil")
        let result = try XCTUnwrap(try sut.handleResponse(responseData), "shouldn't be nil")
        
        XCTAssertEqual(result.count, 1, "should have 1 item")
        XCTAssertEqual(result[0].productId, "identificator", "should have valid `productId`")
        XCTAssertEqual(result[0].products.count, 2, "should have 2 products")
        XCTAssertEqual(result[0].products[0].name, "Apple", "should have valid `name`")
        XCTAssertEqual(result[0].products[0].description, "Some text", "should have valid `description`")
        XCTAssertEqual(result[0].products[0].price, 20.0, "should have valid `price`")
        XCTAssertEqual(result[0].products[0].count, 5, "should have valid `count`")
        XCTAssertEqual(result[0].products[1].name, "Potato", "should have valid `name`")
        XCTAssertEqual(result[0].products[1].description, "Some text", "should have valid `description`")
        XCTAssertEqual(result[0].products[1].price, 16.0, "should have valid `price`")
        XCTAssertEqual(result[0].products[1].count, 50, "should have valid `count`")
    }
    
    func test_responseHandling_withInvalidData() throws {
        let responseData = try XCTUnwrap(invalidJsonData(), "shouldn't be nil")
        
        XCTAssertThrowsError(try sut.handleResponse(responseData)) { error in
            XCTAssertTrue(error is NetworkError, "thrown error should have valid type")
            XCTAssertEqual((error as? NetworkError)?.title, "Serialization error", "thrown error should have valid title")
            XCTAssertTrue(
                (error as? NetworkError)?.detail?.starts(with: "Couldn't parse") == true,
                "thrown error should have valid detail"
            )
        }
    }
    
    // MARK: Helpers
    
    private func validJsonData() throws -> Data {
        let json: [String: Any] = [
            "recoms": [
                [
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
            ]
        ]
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func invalidJsonData() throws -> Data {
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
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }

}
