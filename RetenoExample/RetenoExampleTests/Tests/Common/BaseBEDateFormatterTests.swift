//
//  BaseBEDateFormatterTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 27.09.2022.
//

import XCTest
@testable import Reteno

final class BaseBEDateFormatterTests: XCTestCase {
    
    private let fixedDate = Date(timeIntervalSince1970: 1664309751)
    private var sut: ISO8601DateFormatter!
    
    override func tearDown() {
        sut = nil
    }
    
    func test_formatter() {
        sut = DateFormatter.baseBEDateFormatter
        
        let predictedTimeString = "2022-09-27T20:15:51Z"
        XCTAssertEqual(
            predictedTimeString,
            sut.string(from: fixedDate),
            "string from sut should be equal to \(predictedTimeString)"
        )
    }
    
}
