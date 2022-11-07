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
    private var sut: DateFormatter = .baseBEDateFormatter
    
    override func tearDown() {
        sut.timeZone = TimeZone(abbreviation: "UTC")
    }
    
    func test_formatter_inTimezone3() {
        sut.timeZone = .init(secondsFromGMT: 10800)
        
        let predictedTimeString = "2022-09-27T23:15:51Z"
        XCTAssertEqual(
            predictedTimeString,
            sut.string(from: fixedDate),
            "string from sut should be equal to \(predictedTimeString)"
        )
    }
    
    func test_formatter_inTimezone0() {
        sut.timeZone = .init(secondsFromGMT: 0)
        
        let predictedTimeString = "2022-09-27T20:15:51Z"
        XCTAssertEqual(
            predictedTimeString,
            sut.string(from: fixedDate),
            "string from sut should be equal to \(predictedTimeString)"
        )
    }
    
}
