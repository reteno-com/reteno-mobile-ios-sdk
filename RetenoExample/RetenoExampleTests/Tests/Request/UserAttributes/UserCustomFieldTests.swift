//
//  UserCustomFieldTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 14.10.2022.
//

import XCTest
@testable import Reteno

final class UserCustomFieldTests: XCTestCase {
    
    func test_toJSON_withAllRequiredData() throws {
        let key = "testingKey"
        let value = "testingValue"
        let sut = UserCustomField(key: key, value: value)
        let json = sut.toJSON()
        
        let actualKey = try XCTUnwrap(json["key"] as? String, "actualKey shouldn't be nil")
        XCTAssertEqual(actualKey, key, "actualKey should be equeal to \(key)")
        
        let actualValue = try XCTUnwrap(json["value"] as? String, "actualValue shouldn't be nil")
        XCTAssertEqual(actualValue, value, "actualValue should be equeal to \(value)")
    }
    
}
