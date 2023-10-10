//
//  UserAttributesTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 14.10.2022.
//

import XCTest
@testable import Reteno

final class UserAttributesTests: XCTestCase {
    
    func test_toJSON_withAllRequiredData() throws {
        let phone = "000000000"
        let email = "test@test.com"
        let firstName = "firstName"
        let lastName = "lastName"
        let languageCode = "ua"
        let timeZone = "Kyiv/Ukraine"
        let address = Address(region: "fdksfl", town: "dskdsl", address: "kfmslk", postcode: "dkslas")
        let fiels = UserCustomField(key: "key", value: "value")
        
        let sut = UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            languageCode: languageCode,
            timeZone: timeZone,
            address: address,
            fields: [fiels]
        )
        
        let json = try XCTUnwrap(sut.toJSON(), "json shouldn't be nil")
        let actualPhone = try XCTUnwrap(json["phone"] as? String, "actualPhone shouldn't be nil")
        XCTAssertEqual(actualPhone, phone, "actualPhone should be equal to \(phone)")
        let actualEmail = try XCTUnwrap(json["email"] as? String, "actualEmail shouldn't be nil")
        XCTAssertEqual(actualEmail, email, "actualEmail should be equal to \(email)")
        let actualFirstName = try XCTUnwrap(json["firstName"] as? String, "actualFirstName shouldn't be nil")
        XCTAssertEqual(actualFirstName, firstName, "actualFirstName should be equal to \(firstName)")
        let actualLastName = try XCTUnwrap(json["lastName"] as? String, "actualLastName shouldn't be nil")
        XCTAssertEqual(actualLastName, lastName, "actualLastName should be equal to \(lastName)")
        let actualLanguageCode = try XCTUnwrap(json["languageCode"] as? String, "actualLanguageCode shouldn't be nil")
        XCTAssertEqual(actualLanguageCode, languageCode, "actualLanguageCode should be equal to \(languageCode)")
        let actualTimeZone = try XCTUnwrap(json["timeZone"] as? String, "actualTimeZone shouldn't be nil")
        XCTAssertEqual(actualTimeZone, timeZone, "actualTimeZone should be equal to \(timeZone)")
        XCTAssertNotNil(json["address"], "address shouldn't be nil")
        let actualFields = try XCTUnwrap(json["fields"] as? [[String: Any]], "actualFields shouldn't be nil")
        XCTAssertFalse(actualFields.isEmpty, "actualFields shouldn't be empty")
    }
    
    func test_toJSON_withoutAnyData() {
        let sut = UserAttributes(
            phone: nil,
            email: nil,
            firstName: nil,
            lastName: nil,
            languageCode: nil,
            timeZone: nil,
            address: nil,
            fields: []
        )
        
        XCTAssertNil(sut.toJSON(), "json should be nill")
    }
    
    func test_toEqual_Users() {
        let phone = "000000000"
        let email = "test@test.com"
        let firstName = "firstName"
        let lastName = "lastName"
        let languageCode = "ua"
        let timeZone = "Kyiv/Ukraine"
        let address = Address(region: "fdksfl", town: "dskdsl", address: "kfmslk", postcode: "dkslas")
        let fiels = UserCustomField(key: "key", value: "value")
        
        let sut = UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            languageCode: languageCode,
            timeZone: timeZone,
            address: address,
            fields: [fiels]
        )
        
        let sut2 = UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            languageCode: languageCode,
            timeZone: timeZone,
            address: address,
            fields: [fiels]
        )
        
        let user = User(externalUserId: "1", userAttributes: sut, subscriptionKeys: [], groupNamesInclude: [], groupNamesExclude: [], isAnonymous: false)
        let user2 =  User(externalUserId: "1", userAttributes: sut2, subscriptionKeys: [], groupNamesInclude: [], groupNamesExclude: [], isAnonymous: false)
        
        XCTAssertTrue(user == user2, "users should be the same")
    }
    
    func test_toNotEqual_Users() {
        let phone = "000000000"
        let email = "test@test.com"
        let firstName = "firstName"
        let lastName = "lastName"
        let languageCode = "ua"
        let timeZone = "Kyiv/Ukraine"
        let address = Address(region: "fdksfl", town: "dskdsl", address: "kfmslk", postcode: "dkslas")
        let address2 = Address(region: "fdksfl", town: "dskdsl", address: "kfmslk", postcode: "dkslas")
        let fiels = UserCustomField(key: "key", value: "value")
        let fiels2 = UserCustomField(key: "key", value: "value")
        
        let sut = UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            languageCode: languageCode,
            timeZone: timeZone,
            address: address,
            fields: [fiels]
        )
        
        let sut2 = UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            languageCode: languageCode,
            timeZone: timeZone,
            address: address2,
            fields: [fiels2]
        )
        
        let user = User(externalUserId: "1", userAttributes: sut, subscriptionKeys: ["1"], groupNamesInclude: [], groupNamesExclude: [], isAnonymous: false)
        let user2 =  User(externalUserId: "1", userAttributes: sut2, subscriptionKeys: [], groupNamesInclude: ["2"], groupNamesExclude: [], isAnonymous: false)
        
        XCTAssertTrue(user != user2, "users shouldn't be the same")
    }
}
