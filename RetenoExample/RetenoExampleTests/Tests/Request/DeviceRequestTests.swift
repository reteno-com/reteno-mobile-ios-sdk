//
//  DeviceRequestTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 04.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class DeviceRequestTests: XCTestCase {
    
    func test_deviceRequest_withAllRequiredDataAndMobileDeviceCategory() throws {
        let category = DeviceCategory.mobile
        let osType = "iOS"
        let osVersion = "16.0"
        let deviceModel = "iPhone 12"
        let languageCode = "ua"
        let advertisingId = "klsvdnslkndknlsnkdjkslklsdnd"
        let timeZone = "Kyiv/Ukraine"
        let appVersion = "1.0.0"
        let pushToken = "skdnvjklsvdklnvdskvsdknlsvdklnsdbklnsdlknsd"
        let email = "example@email.com"
        let phone = "+380681234567"
        
        let request = DeviceRequest(
            category: category,
            osType: osType,
            osVersion: osVersion,
            deviceModel: deviceModel,
            languageCode: languageCode,
            advertisingId: advertisingId,
            timeZone: timeZone,
            pushToken: pushToken,
            isSubscribedOnPush: true,
            appVersion: appVersion,
            email: email,
            phone: phone
        )
        
        XCTAssertEqual(
            "v1/device",
            request.path,
            "request.path should be equal to v1/device"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldn't be nil")
        let categoryString = try XCTUnwrap(parameters["category"] as? String, "categoryString shouldn't be nil")
        XCTAssertEqual(categoryString, category.rawValue, "categoryString shoud be equal to \(category.rawValue)")
        let osTypeString = try XCTUnwrap(parameters["osType"] as? String, "osTypeString shouldn't be nil")
        XCTAssertEqual(osTypeString, osType, "osTypeString shoud be equal to \(osType)")
        let osVersionString = try XCTUnwrap(parameters["osVersion"] as? String, "osVersionString shouldn't be nil")
        XCTAssertEqual(osVersionString, osVersion, "osVersionString shoud be equal to \(osVersion)")
        let deviceModelString = try XCTUnwrap(parameters["deviceModel"] as? String, "deviceModelString shouldn't be nil")
        XCTAssertEqual(deviceModelString, deviceModel, "deviceModelString shoud be equal to \(deviceModel)")
        let languageCodeString = try XCTUnwrap(parameters["languageCode"] as? String, "languageCodeString shouldn't be nil")
        XCTAssertEqual(languageCodeString, languageCode, "languageCodeString shoud be equal to \(languageCode)")
        let advertisingIdString = try XCTUnwrap(parameters["advertisingId"] as? String, "advertisingIdString shouldn't be nil")
        XCTAssertEqual(advertisingIdString, advertisingId, "advertisingIdString shoud be equal to \(advertisingId)")
        let timeZoneString = try XCTUnwrap(parameters["timeZone"] as? String, "timeZoneString shouldn't be nil")
        XCTAssertEqual(timeZoneString, timeZone, "timeZoneString shoud be equal to \(timeZone)")
        let appVersionString = try XCTUnwrap(parameters["appVersion"] as? String, "appVersionString shouldn't be nil")
        XCTAssertEqual(appVersionString, appVersion, "appVersionString shoud be equal to \(appVersion)")
        let pushTokenString = try XCTUnwrap(parameters["pushToken"] as? String, "pushTokenString shouldn't be nil")
        XCTAssertEqual(pushTokenString, pushToken, "pushTokenString should be equal to \(pushToken)")
        let isSubscribedOnPush = try XCTUnwrap(parameters["pushSubscribed"] as? Bool, "pushSubscribed shouldn't be nil")
        XCTAssertTrue(isSubscribedOnPush, "pushSubscribed should be true")
        let emailString = try XCTUnwrap(parameters["email"] as? String, "emailString shouldn't be nil")
        XCTAssertEqual(emailString, email, "emailString should be equal to \(email)")
        let phoneString = try XCTUnwrap(parameters["phone"] as? String, "emailString shouldn't be nil")
        XCTAssertEqual(phoneString, phone, "phoneString be equal to \(phone)")
    }
    
    func test_deviceRequest_withoutOptionalDataAndTabletDeviceCategory() throws {
        let category = DeviceCategory.tablet
        let osType = "iOS"
        let osVersion = "16.0"
        let deviceModel = "iPhone 12"
        let timeZone = "Kyiv/Ukraine"
        let pushToken = "skdnvjklsvdklnvdskvsdknlsvdklnsdbklnsdlknsd"
        let email = "example@email.com"
        let phone = "+380681234567"

        let request = DeviceRequest(
            category: category,
            osType: osType,
            osVersion: osVersion,
            deviceModel: deviceModel,
            timeZone: timeZone,
            pushToken: pushToken,
            isSubscribedOnPush: true,
            email: email,
            phone: phone
        )
        
        XCTAssertEqual(
            "v1/device",
            request.path,
            "request.path should be equal to v1/device"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldn't be nil")
        let categoryString = try XCTUnwrap(parameters["category"] as? String, "categoryString shouldn't be nill")
        XCTAssertEqual(categoryString, category.rawValue, "categoryString shoud be equal to \(category.rawValue)")
        let osTypeString = try XCTUnwrap(parameters["osType"] as? String, "osTypeString shouldn't be nill")
        XCTAssertEqual(osTypeString, osType, "osTypeString shoud be equal to \(osType)")
        let osVersionString = try XCTUnwrap(parameters["osVersion"] as? String, "osVersionString shouldn't be nill")
        XCTAssertEqual(osVersionString, osVersion, "osVersionString shoud be equal to \(osVersion)")
        let deviceModelString = try XCTUnwrap(parameters["deviceModel"] as? String, "deviceModelString shouldn't be nill")
        XCTAssertEqual(deviceModelString, deviceModel, "deviceModelString shoud be equal to \(deviceModel)")
        XCTAssertNil(parameters["languageCode"], "languageCode should be nill")
        XCTAssertNil(parameters["advertisingId"], "advertisingId should be nill")
        let timeZoneString = try XCTUnwrap(parameters["timeZone"] as? String, "timeZoneString shouldn't be nill")
        XCTAssertEqual(timeZoneString, timeZone, "timeZoneString shoud be equal to \(timeZone)")
        let pushTokenString = try XCTUnwrap(parameters["pushToken"] as? String, "pushTokenString shouldn't be nill")
        XCTAssertEqual(pushTokenString, pushToken, "pushTokenString should be equal to \(pushToken)")
        let isSubscribedOnPush = try XCTUnwrap(parameters["pushSubscribed"] as? Bool, "pushSubscribed shouldn't be nil")
        XCTAssertTrue(isSubscribedOnPush, "pushSubscribed should be true")
        let emailString = try XCTUnwrap(parameters["email"] as? String, "email shouldn't be nill")
        XCTAssertEqual(emailString, email, "emailString should be equal to \(email)")
        let phoneString = try XCTUnwrap(parameters["phone"] as? String, "phone shouldn't be nill")
        XCTAssertEqual(phoneString, phone, "phoneString should be equal to \(phone)")
    }
    
}
