//
//  DateExtensionsTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 18.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class DateExtensionsTests: XCTestCase {

    func test_hoursBetweenDates_withPositiveResult() {
        let firstDate = Date(timeIntervalSince1970: 1666087200)
        let secondDate = Date(timeIntervalSince1970: 1666123200)
        
        let result = secondDate.hours(from: firstDate)
        XCTAssertEqual(result, 10, "should be 10 hours")
    }
    
    func test_hoursBetweenDates_withNegativeResult() {
        let firstDate = Date(timeIntervalSince1970: 1666087200)
        let secondDate = Date(timeIntervalSince1970: 1666105200)
        
        let result = firstDate.hours(from: secondDate)
        XCTAssertEqual(result, -5, "should be -5 hours")
    }
    
    func test_hoursBetweenDates_withZeroResult() {
        let firstDate = Date(timeIntervalSince1970: 1666105200)
        let secondDate = Date(timeIntervalSince1970: 1666107000)
        
        let result = secondDate.hours(from: firstDate)
        XCTAssertEqual(result, 0, "should be 0 hours")
    }
    
}
