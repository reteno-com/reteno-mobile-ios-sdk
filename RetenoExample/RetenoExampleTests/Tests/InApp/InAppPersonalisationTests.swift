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

extension InAppPersonalisationTests {
    func test_delivery_html_keeps_raw_model_and_each_executions_prepared_map() throws {
        let model = ["title": "Hello ${firstName}", "email": "${email}"]
        let renderer = InAppPersonalisation(values: ["firstName": "Cached user", "email": "cached@example.com"])
        let template = "const model = ${documentModel}; const personalisation = ${personalisation};"
        var html: [String] = []
        for (iid, name, email) in [("11111111-1111-4111-8111-111111111111", "Alice", "alice@example.com"),
                                   ("22222222-2222-4222-8222-222222222222", "Bob", "bob@example.com")] {
            let data = try JSONSerialization.data(withJSONObject: ["iid": iid, "messageInstanceId": 80,
                "layoutType": "FULL", "model": model,
                "personalisation": ["firstName": name, "email": email]])
            var content = try JSONDecoder().decode(InAppContent.self, from: data)
            let prepared = renderer.prepareHTML(template, for: content)
            XCTAssertTrue(prepared.contains("Hello ${firstName}"))
            XCTAssertTrue(prepared.contains("${email}"))
            XCTAssertTrue(prepared.contains(name))
            XCTAssertTrue(prepared.contains(email))
            XCTAssertFalse(prepared.contains("Cached user"))
            XCTAssertFalse(prepared.contains("cached@example.com"))
            html.append(prepared)
        }
        XCTAssertNotEqual(html[0], html[1])
        let ordinary = InAppMessage(id: "ordinary", model: #"{"title":"Hello ${firstName}","email":"${email}"}"#,
                                    personalisation: nil)
        let ordinaryHTML = renderer.prepareHTML(template, for: ordinary)
        XCTAssertTrue(ordinaryHTML.contains("Hello Cached user"))
        XCTAssertTrue(ordinaryHTML.contains("cached@example.com"))
        XCTAssertFalse(ordinaryHTML.contains("${firstName}"))
    }
}
