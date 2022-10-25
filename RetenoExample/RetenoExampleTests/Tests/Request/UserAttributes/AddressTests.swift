//
//  AddressTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 14.10.2022.
//

import XCTest
@testable import Reteno

final class AddressTests: XCTestCase {
    
    func test_toJSON_withAllAvailableData() throws {
        let region = "Ukraine"
        let town = "Lviv"
        let addressLine = "Stepana Bandery 33"
        let postcode = "79000"
        let address = Address(region: region, town: town, address: addressLine, postcode: postcode)
        
        let json = try XCTUnwrap(address.toJSON(), "json shouldn't be nil")
        let actualRegion = try XCTUnwrap(json["region"] as? String, "actualRegion shouldn't be nil")
        XCTAssertEqual(actualRegion, region, "actualRegion should be equal to \(region)")
        let actualTown = try XCTUnwrap(json["town"] as? String, "actualTown shouldn't be nil")
        XCTAssertEqual(actualTown, town, "actualTown should be equal to \(actualTown)")
        let actualAddress = try XCTUnwrap(json["address"] as? String, "actualAddress shouldn't be nil")
        XCTAssertEqual(actualAddress, addressLine, "actualAddress should be equal to \(addressLine)")
        let actualPostcode = try XCTUnwrap(json["postcode"] as? String, "actualPostcode shouldn't be nil")
        XCTAssertEqual(actualPostcode, postcode, "actualPostcode should be equal to \(postcode)")
    }
    
    func test_toJSON_withoutAnyData() {
        let address = Address()
        
        XCTAssertNil(address.toJSON(), "json should be nill")
    }
    
}
