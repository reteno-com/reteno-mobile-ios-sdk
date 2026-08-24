//
//  InAppPersonalisationTests.swift
//  RetenoExampleTests
//
//  Created by George Farafonov on 19.08.2026.
//

import XCTest
@testable import Reteno

final class InAppPersonalisationTests: XCTestCase {
    
    func test_apply_replacesSupportedPlaceholdersWithUserAttributes() {
        let sut = InAppPersonalisation(values: ["firstName": "John", "email": "test@test.com"])
        
        let result = sut.apply(to: #"{"textContent":"Hi ${firstName}, we write to ${email}"}"#)
        
        XCTAssertEqual(result, #"{"textContent":"Hi John, we write to test@test.com"}"#)
    }
    
    func test_apply_replacesRepeatedPlaceholder() {
        let sut = InAppPersonalisation(values: ["firstName": "John"])
        
        let result = sut.apply(to: "${firstName} ${firstName}")
        
        XCTAssertEqual(result, "John John")
    }
    
    func test_apply_resolvesUnknownAttributeToEmptyString() {
        let sut = InAppPersonalisation(values: ["firstName": "John"])
        
        let result = sut.apply(to: "Hi ${firstName} ${lastName}!")
        
        XCTAssertEqual(result, "Hi John !")
    }
    
    func test_apply_keepsUnsupportedPlaceholders() {
        let sut = InAppPersonalisation(values: ["email": "test@test.com"])
        
        let result = sut.apply(to: "${documentModel} ${personalisation} ${unknownKey}")
        
        XCTAssertEqual(result, "${documentModel} ${personalisation} ${unknownKey}")
    }
    
    func test_apply_withoutPlaceholders_keepsContentUnchanged() {
        let sut = InAppPersonalisation(values: ["email": "test@test.com"])
        let content = #"{"textContent":"Special offer"}"#
        
        XCTAssertEqual(sut.apply(to: content), content)
    }
    
    func test_apply_keepsModelValidJSON_whenValueContainsSpecialCharacters() throws {
        let firstName = #"Jo"hn \ <b>"#
        let sut = InAppPersonalisation(values: ["firstName": firstName])
        
        let result = sut.apply(to: #"{"textContent":"Hi ${firstName}"}"#)
        
        XCTAssertFalse(result.contains("<b>"), "html tags should be escaped to not break out of the script tag")
        let data = try XCTUnwrap(result.data(using: .utf8), "data shouldn't be nil")
        let json = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any],
            "personalised model should stay a valid JSON"
        )
        XCTAssertEqual(json["textContent"] as? String, "Hi \(firstName)")
    }
    
    func test_personalisationValues_flattensAddressAndSkipsCustomFields() throws {
        let attributes = UserAttributes(
            phone: "000000000",
            email: "test@test.com",
            firstName: "firstName",
            lastName: "lastName",
            languageCode: "ua",
            timeZone: "Kyiv/Ukraine",
            marketId: "1",
            address: Address(region: "region", town: "town", address: "address", postcode: "postcode"),
            fields: [UserCustomField(key: "key", value: "value")]
        )
        
        let values = attributes.personalisationValues()
        
        XCTAssertEqual(
            values,
            [
                "phone": "000000000",
                "email": "test@test.com",
                "firstName": "firstName",
                "lastName": "lastName",
                "languageCode": "ua",
                "timeZone": "Kyiv/Ukraine",
                "marketId": "1",
                "region": "region",
                "town": "town",
                "address": "address",
                "postcode": "postcode"
            ]
        )
        XCTAssertTrue(
            Set(values.keys).isSubset(of: InAppPersonalisation.supportedKeys),
            "all values should be reachable through supported placeholders"
        )
    }
    
    func test_personalisationValues_skipsNotSetAttributes() {
        let attributes = UserAttributes(firstName: "firstName", timeZone: nil)
        
        XCTAssertEqual(attributes.personalisationValues(), ["firstName": "firstName"])
    }
    
}
