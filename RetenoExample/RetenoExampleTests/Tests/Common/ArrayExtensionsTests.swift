//
//  ArrayExtensionsTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 19.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ArrayExtensionsTests: XCTestCase {

    func test_isNotEmpty_forEmptyArray() {
        let sut: [Int] = []
        XCTAssertFalse(sut.isNotEmpty, "should be false")
    }
    
    func test_isNotEmpty_forArrayWithValues() {
        let sut = [0, 1, 2]
        XCTAssertTrue(sut.isNotEmpty, "should be true")
    }

}
