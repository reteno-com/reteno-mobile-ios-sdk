//
//  ItemTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 11.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ItemTests: XCTestCase {

    private var sut: Ecommerce.Order.Item!
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_converttoJSON() {
        sut = Ecommerce.Order.Item(
            externalItemId: "utu7",
            name: "shirt",
            category: "summer",
            quantity: 1.0,
            cost: 300.0,
            url: "some url",
            imageUrl: "some url",
            description: "super shirt"
        )
        let result = sut.toJSON()
        XCTAssertEqual(result["externalItemId"] as? String, "utu7", "should contains valid externalItemId parameter")
        XCTAssertEqual(result["name"] as? String, "shirt", "should contains valid name parameter")
        XCTAssertEqual(result["quantity"] as? Double, 1.0, "should contains valid quantity parameter")
        XCTAssertEqual(result["cost"] as? Float, 300.0, "should contains valid cost parameter")
        XCTAssertEqual(result["category"] as? String, "summer", "should contains valid category parameter")
        XCTAssertEqual(result["url"] as? String, "some url", "should contains valid url parameter")
        XCTAssertEqual(result["imageUrl"] as? String, "some url", "should contains valid imageUrl parameter")
        XCTAssertEqual(result["description"] as? String, "super shirt", "should contains valid description parameter")
    }

}
