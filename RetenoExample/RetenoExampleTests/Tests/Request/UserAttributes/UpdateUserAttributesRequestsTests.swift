//
//  UpdateUserAttributesRequestsTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 14.10.2022.
//

import XCTest
import Alamofire
@testable import Reteno

final class UpdateUserAttributesRequestsTests: XCTestCase {
    
    func test_createRequest_withAllRequiredData() throws {
        let deviceId = "dsklaskldsaksankl"
        let externalUserId = "dasnsvbjskndclm;as"
        let request = UpdateUserAttributesRequest(
            externalUserId: externalUserId,
            deviceId: deviceId,
            userAttributes: UserAttributes(phone: "000021312", email: "test@test.com"),
            subscriptionKeys: ["key1", "key2"],
            groupNamesInclude: ["group1", "group2"],
            groupNamesExclude: ["group3", "group4"]
        )
        
        XCTAssertEqual(
            "v1/user",
            request.path,
            "request.path should be equal to v1/user"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldn't be nil")
        let actualDeviceId = try XCTUnwrap(parameters["deviceId"] as? String, "deviceId shouldn't be nil")
        XCTAssertEqual(deviceId, actualDeviceId, "actualDeviceId should be equal to \(deviceId)")
        let actualExternalUserId = try XCTUnwrap(parameters["externalUserId"] as? String, "externalUserId shouldn't be nil")
        XCTAssertEqual(externalUserId, actualExternalUserId, "actualExternalUserId should be equal to \(externalUserId)")
        XCTAssertNotNil(parameters["userAttributes"], "userAttributes shouldn't be nil")
        let actualSubscriptionKeys = try XCTUnwrap(parameters["subscriptionKeys"] as? [String], "subscriptionKeys shouldn't be nil")
        XCTAssertFalse(actualSubscriptionKeys.isEmpty, "actualSubscriptionKeys shouldn't be empty")
        let actualGroupNamesInclude = try XCTUnwrap(parameters["groupNamesInclude"] as? [String], "groupNamesInclude shouldn't be nil")
        XCTAssertFalse(actualGroupNamesInclude.isEmpty, "actualGroupNamesInclude shouldn't be empty")
        let actualGroupNamesExclude = try XCTUnwrap(parameters["groupNamesExclude"] as? [String], "groupNamesExclude shouldn't be nil")
        XCTAssertFalse(actualGroupNamesExclude.isEmpty, "actualGroupNamesExclude shouldn't be empty")
    }
    
    func test_createRequest_withDeviceIdAndExternalUserId() throws {
        let deviceId = "dsklaskldsaksankl"
        let externalUserId = "dasnsvbjskndclm;as"
        let request = UpdateUserAttributesRequest(
            externalUserId: externalUserId,
            deviceId: deviceId,
            userAttributes: nil,
            subscriptionKeys: []
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldn't be nil")
        let actualDeviceId = try XCTUnwrap(parameters["deviceId"] as? String, "deviceId shouldn't be nil")
        XCTAssertEqual(deviceId, actualDeviceId, "actualDeviceId should be equal to \(deviceId)")
        let actualExternalUserId = try XCTUnwrap(parameters["externalUserId"] as? String, "externalUserId shouldn't be nil")
        XCTAssertEqual(externalUserId, actualExternalUserId, "actualExternalUserId should be equal to \(externalUserId)")
        XCTAssertNil(parameters["userAttributes"], "userAttributes should be nil")
        XCTAssertNil(parameters["subscriptionKeys"], "subscriptionKeys should be nil")
        XCTAssertNil(parameters["groupNamesInclude"], "subscriptionKeys should be nil")
        XCTAssertNil(parameters["groupNamesExclude"], "subscriptionKeys should be nil")
    }
    
}
