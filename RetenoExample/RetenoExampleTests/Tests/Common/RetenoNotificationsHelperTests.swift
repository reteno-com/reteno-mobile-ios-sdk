//
//  RetenoNotificationsHelperTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class RetenoNotificationsHelperTests: XCTestCase {
    
    func test_isRetenoPushNotification_withInteractionId() {
        let userInfo: [AnyHashable: Any] = ["es_interaction_id": "5hhhf88cb", "es_title": "Title"]
        let result = RetenoNotificationsHelper.isRetenoPushNotification(userInfo)
        XCTAssertTrue(result, "should be true")
    }

    func test_isRetenoPushNotification_withoutInteractionId() {
        let userInfo: [AnyHashable: Any] = ["es_title": "Title"]
        let result = RetenoNotificationsHelper.isRetenoPushNotification(userInfo)
        XCTAssertFalse(result, "should be false")
    }
    
}
