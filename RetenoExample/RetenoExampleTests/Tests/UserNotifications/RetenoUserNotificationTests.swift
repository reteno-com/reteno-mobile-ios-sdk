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
    
    func test_userNotificationInitialization_fromPayload_withButtons() throws {
        let userInfo: [AnyHashable: Any] = [
            "es_interaction_id": "656dgggf66",
            "es_buttons": "[{\"action_id\":\"1\",\"label\":\"Text1\",\"ios_icon_path\":\"mail\",\"link\":\"some_url\",\"link_raw\":\"some_raw_url\",\"custom_data\":{\"id\":\"1\",\"title\":\"Test Title\"}}]"
        ]
        let result = try XCTUnwrap(RetenoUserNotification(userInfo: userInfo), "should have value")
        
        XCTAssertEqual(result.id, "656dgggf66", "should have valid `id`")
        XCTAssertNotNil(result.actionButtons, "should have action buttons")
        XCTAssertEqual(result.actionButtons?[0].actionId, "1", "should have valid button actionId")
        XCTAssertEqual(result.actionButtons?[0].title, "Text1", "should have valid button title")
        XCTAssertEqual(result.actionButtons?[0].iconPath, "mail", "should have valid button iconPath")
        XCTAssertEqual(result.actionButtons?[0].link?.absoluteString, "some_url", "should have valid button link")
        XCTAssertEqual(result.actionButtons?[0].rawLink?.absoluteString, "some_raw_url", "should have valid button rawLink")
        
        let buttonCustomData = try XCTUnwrap(result.actionButtons?[0].customData, "should have value")
        XCTAssertEqual(buttonCustomData["id"] as? String, "1", "should have valid button customData")
        XCTAssertEqual(buttonCustomData["title"] as? String, "Test Title", "should have valid button customData")
    }
}
