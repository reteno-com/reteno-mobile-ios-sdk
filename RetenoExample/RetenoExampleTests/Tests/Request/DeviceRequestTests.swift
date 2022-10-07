//
//  DeviceRequestTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 04.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import Alamofire
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
        
        let request = DeviceRequest(
            category: category,
            osType: osType,
            osVersion: osVersion,
            deviceModel: deviceModel,
            languageCode: languageCode,
            advertisingId: advertisingId,
            timeZone: timeZone,
            pushToken: pushToken,
            appVersion: appVersion
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
        let languageCodeString = try XCTUnwrap(parameters["languageCode"] as? String, "languageCodeString shouldn't be nill")
        XCTAssertEqual(languageCodeString, languageCode, "languageCodeString shoud be equal to \(languageCode)")
        let advertisingIdString = try XCTUnwrap(parameters["advertisingId"] as? String, "advertisingIdString shouldn't be nill")
        XCTAssertEqual(advertisingIdString, advertisingId, "advertisingIdString shoud be equal to \(advertisingId)")
        let timeZoneString = try XCTUnwrap(parameters["timeZone"] as? String, "timeZoneString shouldn't be nill")
        XCTAssertEqual(timeZoneString, timeZone, "timeZoneString shoud be equal to \(timeZone)")
        let appVersionString = try XCTUnwrap(parameters["appVersion"] as? String, "appVersionString shouldn't be nill")
        XCTAssertEqual(appVersionString, appVersion, "appVersionString shoud be equal to \(appVersion)")
        let pushTokenString = try XCTUnwrap(parameters["pushToken"] as? String, "pushTokenString shouldn't be nill")
        XCTAssertEqual(pushTokenString, pushToken, "pushTokenString should be equal to \(pushToken)")
    }
    
    func test_deviceRequest_withoutOptionalDataAndTabletDeviceCategory() throws {
        let category = DeviceCategory.tablet
        let osType = "iOS"
        let osVersion = "16.0"
        let deviceModel = "iPhone 12"
        let timeZone = "Kyiv/Ukraine"
        let pushToken = "skdnvjklsvdklnvdskvsdknlsvdklnsdbklnsdlknsd"
        
        let request = DeviceRequest(
            category: category,
            osType: osType,
            osVersion: osVersion,
            deviceModel: deviceModel,
            timeZone: timeZone,
            pushToken: pushToken
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
        XCTAssertNil(parameters["appVersion"], "appVersion should be nill")
        let pushTokenString = try XCTUnwrap(parameters["pushToken"] as? String, "pushTokenString shouldn't be nill")
        XCTAssertEqual(pushTokenString, pushToken, "pushTokenString should be equal to \(pushToken)")
    }
    
}
