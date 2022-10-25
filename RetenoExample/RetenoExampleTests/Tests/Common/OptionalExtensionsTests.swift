//
//  OptionalExtensionsTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 19.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class OptionalExtensionsTests: XCTestCase {

    func test_isSome_forNilValue() {
        let sut: Int? = nil
        XCTAssertFalse(sut.isSome, "should be false")
    }
    
    func test_isSome_forValue() {
        let sut: Int? = 10
        XCTAssertTrue(sut.isSome, "should be true")
    }
    
    func test_isNone_forNilValue() {
        let sut: Int? = nil
        XCTAssertTrue(sut.isNone, "should be true")
    }
    
    func test_isNone_forValue() {
        let sut: Int? = 10
        XCTAssertFalse(sut.isNone, "should be false")
    }

}
