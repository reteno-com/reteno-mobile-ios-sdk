//
//  RetenoUserNotificationTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class RetenoUserNotificationTests: XCTestCase {

    func test_userNotificationInitialization_fromPayload() throws {
        let userInfo: [AnyHashable: Any] = [
            "es_interaction_id": "656dgggf66",
            "es_notification_image": "image_link",
            "es_link": "https://www.google.com/?client=safari"
        ]
        let result = try XCTUnwrap(RetenoUserNotification(userInfo: userInfo), "should have value")
        
        XCTAssertEqual(result.id, "656dgggf66", "should have valid `id`")
        XCTAssertEqual(result.imageURLString, "image_link", "should have valid `imageURLString`")
        XCTAssertEqual(result.link, URL(string: "https://www.google.com/?client=safari"), "should have valid `link`")
    }
    
    func test_userNotificationInitialization_fromPayload_withoutUrl() throws {
        let userInfo: [AnyHashable: Any] = [
            "es_interaction_id": "656dgggf66",
            "es_notification_image": "image_link"
        ]
        let result = try XCTUnwrap(RetenoUserNotification(userInfo: userInfo), "should have value")
        
        XCTAssertEqual(result.id, "656dgggf66", "should have valid `id`")
        XCTAssertEqual(result.imageURLString, "image_link", "should have valid `imageURLString`")
        XCTAssertNil(result.link, "link shoud be nil")
    }
    
    func test_userNotificationInitialization_fromPayload_withLinkAndRawLink() throws {
        let userInfo: [AnyHashable: Any] = [
            "es_interaction_id": "656dgggf66",
            "es_link": "https://www.google.com/?client=safari",
            "es_link_raw": "https://www.google.com/?client=safari"
        ]
        let result = try XCTUnwrap(RetenoUserNotification(userInfo: userInfo), "should have value")
        
        XCTAssertEqual(result.id, "656dgggf66", "should have valid `id`")
        XCTAssertEqual(result.link, URL(string: "https://www.google.com/?client=safari"), "should have valid `link`")
        XCTAssertEqual(result.rawLink, URL(string: "https://www.google.com/?client=safari"), "should have valid `link`")
    }
}
