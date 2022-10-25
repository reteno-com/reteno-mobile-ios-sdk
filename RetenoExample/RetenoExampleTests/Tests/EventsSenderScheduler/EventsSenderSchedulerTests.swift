//
//  EventsSenderSchedulerTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 18.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class EventsSenderSchedulerTests: XCTestCase {
    
    private var sut: EventsSenderScheduler!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests")
        storage = KeyValueStorage(storage: userDefaults)
        sut = EventsSenderScheduler(
            mobileRequestService: MobileRequestServiceBuilder.build(),
            storage: storage,
            sendingService: SendingServiceBuilder.build()
        )
    }
    
    override func tearDown() {
        NotificationCenter.default.removeObserver(self)
        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        userDefaults.removeSuite(named: "unit_tests")
        sut = nil
        HTTPStubs.removeAllStubs()
    }

    func test_updatingNotificationInteractionStatus_withFailedRequest() {
        let expectation = expectation(description: "UserDefaults changed")
        expectation.assertForOverFulfill = false
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        let interactionId = "-1"
        let eventDate = Date()
        stub(condition: pathEndsWith("v1/interactions/\(interactionId)/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        sut.updateNotificationInteractionStatus(interactionId: interactionId, status: .delivered, date: eventDate)
        wait(for: [expectation], timeout: 10.0)
        
        let savedNotification = storage.getNotificationStatuses().first(where: { $0.interactionId == interactionId && $0.date == eventDate })
        XCTAssertTrue(savedNotification.isSome, "status should be stored")
    }
    
    func test_updatingUserAttributes_withFailedRequest() {
        let expectation = expectation(description: "UserDefaults changed")
        expectation.assertForOverFulfill = false
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { _ in
            expectation.fulfill()
        }
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        sut.updateUserAttributes(
            externalUserId: nil, userAttributes: UserAttributes(phone: "0509876543", email: "test@gmail.com", firstName: "John"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: []
        )
        wait(for: [expectation], timeout: 1.0)
        
        let savedUser = storage.getUsers().first(where: {
            $0.userAttributes?.phone == "0509876543" && $0.userAttributes?.email == "test@gmail.com" && $0.userAttributes?.firstName == "John"
        })
        XCTAssertTrue(savedUser.isSome, "userAttributes should be stored")
    }

}
