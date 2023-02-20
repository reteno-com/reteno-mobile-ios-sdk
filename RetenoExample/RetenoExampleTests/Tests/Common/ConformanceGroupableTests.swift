//
//  ConformanceGroupableTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 06.02.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class ConformanceGroupableTests: XCTestCase {

    func test_event_conformance() {
        let result: Groupable = Event(eventTypeKey: ScreenViewEvent, date: Date(), parameters: [.init(name: "name", value: "Anna")])
        XCTAssertEqual(result.key, ScreenViewEvent, "should have valid key")
    }
    
    func test_notificationStatus_conformance() {
        let result: Groupable = NotificationStatus(interactionId: "uu7", status: .delivered, date: Date())
        XCTAssertEqual(result.key, InteractionStatus.delivered.rawValue, "should have valid key")
    }

}
