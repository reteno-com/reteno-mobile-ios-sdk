//
//  OrderTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 11.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class OrderTests: XCTestCase {

    private var sut: Ecommerce.Order!
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
    }
    
    func test_eventParameters() {
        let orderDate = Date()
        sut = Ecommerce.Order(externalOrderId: "fhuf8f", totalCost: 320.0, status: .INITIALIZED, date: orderDate)

        let result = sut.eventParameters()
        XCTAssertTrue(result.count == 4, "should have 4 parameters")
        XCTAssertNotNil(result.first(where: { $0.name == "externalOrderId" }), "should have externalOrderId parameter")
        XCTAssertEqual(
            result.first(where: { $0.name == "externalOrderId" })?.value,
            "fhuf8f",
            "should have valid externalOrderId parameter value"
        )
        XCTAssertNotNil(result.first(where: { $0.name == "totalCost" }), "should have totalCost parameter")
        XCTAssertEqual(
            result.first(where: { $0.name == "totalCost" })?.value,
            "320.0",
            "should have valid totalCost parameter value"
        )
        XCTAssertNotNil(result.first(where: { $0.name == "status" }), "should have status parameter")
        XCTAssertEqual(
            result.first(where: { $0.name == "status" })?.value,
            "INITIALIZED",
            "should have valid status parameter value"
        )
        XCTAssertNotNil(result.first(where: { $0.name == "date" }), "should have date parameter")
        XCTAssertEqual(
            result.first(where: { $0.name == "date" })?.value,
            DateFormatter.baseBEDateFormatter.string(from: orderDate),
            "should have valid date parameter value"
        )
    }

}
