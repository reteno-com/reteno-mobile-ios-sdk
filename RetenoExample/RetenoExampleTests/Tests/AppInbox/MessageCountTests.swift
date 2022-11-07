//
//  MessageCountTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 30.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class MessageCountTests: XCTestCase {
    
    private var requestService: MobileRequestService!
    
    private var userDefaults: UserDefaults!
    private var scheduler: EventsSenderScheduler!
    
    private var sut: AppInbox!
    
    override func setUp() {
        super.setUp()
        
        requestService = MobileRequestService(requestManager: .stub)
        buildScheduler()
        sut = AppInbox(requestService: requestService, scheduler: scheduler)
    }
    
    override func tearDown() {
        super.tearDown()
        
        requestService = nil
        sut = nil
        userDefaults.removeSuite(named: "unit_tests_operations")
        HTTPStubs.removeAllStubs()
    }
    
    private func buildScheduler() {
        userDefaults = UserDefaults(suiteName: "unit_tests_operations")
        let storage = KeyValueStorage(storage: userDefaults)
        let sendingService = SendingServices(requestManager: .stub)
        scheduler = EventsSenderScheduler(
            mobileRequestService: requestService,
            storage: storage,
            sendingService: sendingService,
            timeIntervalResolver: { 1.0 },
            randomOffsetResolver: { 0.0 }
        )
        scheduler.scheduleTask()
    }
    
    func test_messageCountChange_withMessagesCount2AndPositiveResponse() {
        let unreadCount = 2
        stub(condition: pathEndsWith("v1/appinbox/messages/count")) { _ in
            let jsonObject = ["unreadCount": unreadCount]
            
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }
        
        let expectation = expectation(description: "Messages Count")
        sut.onUnreadMessagesCountChanged = { resultCount in
            XCTAssertEqual(resultCount, unreadCount, "resultCount should be equal to \(unreadCount)")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func test_messageCountChange_withMessagesCount2And5() {
        var unreadNumbers = [2, 5]
        stub(condition: pathEndsWith("v1/appinbox/messages/count")) { _ in
            let jsonObject = ["unreadCount": unreadNumbers.first ?? 0]
            
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }
        
        var numberOfChanges = 0
        let expectation = expectation(description: "Messages Count")
        sut.onUnreadMessagesCountChanged = { resultCount in
            let stubUnreadCount = unreadNumbers.removeFirst()
            XCTAssertEqual(resultCount, stubUnreadCount, "resultCount should be equal to \(stubUnreadCount)")
            numberOfChanges += 1
            
            guard numberOfChanges == 2 else { return }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
        XCTAssertEqual(numberOfChanges, 2, "Counter should be changed 2 times")
        XCTAssertTrue(unreadNumbers.isEmpty, "unreadNumbers should be empty")
    }
    
    func test_messageCountChange_withMessagesCounts2_2_3_3_5_5() {
        var unreadNumbers = [2, 2, 3, 3, 5, 5]
        var uniqueUnreadNumbers = Set(unreadNumbers)
        let targetNumberOfChanges = uniqueUnreadNumbers.count
        stub(condition: pathEndsWith("v1/appinbox/messages/count")) { _ in
            let jsonObject = ["unreadCount": unreadNumbers.removeFirst()]
            
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }
        
        var numberOfChanges = 0
        let expectation = expectation(description: "Messages Count")
        sut.onUnreadMessagesCountChanged = { resultCount in
            XCTAssertTrue(
                uniqueUnreadNumbers.contains(resultCount),
                "resultCount should be contained in uniqueUnreadNumbers"
            )
            uniqueUnreadNumbers.remove(resultCount)
            numberOfChanges += 1
            
            guard numberOfChanges == targetNumberOfChanges else { return }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 6.0)
        XCTAssertEqual(numberOfChanges, targetNumberOfChanges, "Counter should be changed \(targetNumberOfChanges) times")
        XCTAssertTrue(unreadNumbers.isNotEmpty, "unreadNumbers shouldn't be empty")
    }
    
    func test_messageCountChange_withMessagesCounts2_3_4_5_5_5_5_5_6() {
        var unreadNumbers = [2, 3, 4, 5, 5, 5, 5, 5, 6]
        var uniqueUnreadNumbers = Set(unreadNumbers)
        let targetNumberOfChanges = uniqueUnreadNumbers.count
        stub(condition: pathEndsWith("v1/appinbox/messages/count")) { _ in
            let jsonObject = ["unreadCount": unreadNumbers.removeFirst()]
            
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: nil)
        }
        
        var numberOfChanges = 0
        let expectation = expectation(description: "Messages Count")
        sut.onUnreadMessagesCountChanged = { resultCount in
            XCTAssertTrue(
                uniqueUnreadNumbers.contains(resultCount),
                "resultCount should be contained in uniqueUnreadNumbers"
            )
            uniqueUnreadNumbers.remove(resultCount)
            numberOfChanges += 1
            
            guard numberOfChanges == targetNumberOfChanges else { return }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
        XCTAssertEqual(numberOfChanges, targetNumberOfChanges, "Counter should be changed \(targetNumberOfChanges) times")
        XCTAssertTrue(unreadNumbers.isEmpty, "unreadNumbers should be empty")
    }
    
}
