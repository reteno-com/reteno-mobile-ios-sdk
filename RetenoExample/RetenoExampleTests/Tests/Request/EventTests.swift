//
//  EventTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 04.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class EventTests: XCTestCase {

    func test_convertingEventToJSON() {
        let event = Event(
            eventTypeKey: "type_key",
            date: Date(timeIntervalSince1970: 1664892583),
            parameters: [Event.Parameter(name: "parameter_name", value: "parameter_value")]
        )
        let result = event.toJSON()
        XCTAssertEqual(result["eventTypeKey"] as? String, "type_key", "should have valid `eventTypeKey` parameter")
        XCTAssertEqual(result["occurred"] as? String, "2022-10-04T02:09:43Z", "should have valid `occurred` parameter")
        XCTAssertEqual(
            result["params"] as? [[String: String]],
            [["name": "parameter_name", "value": "parameter_value"]],
            "should have valid `params`"
        )
    }

}
