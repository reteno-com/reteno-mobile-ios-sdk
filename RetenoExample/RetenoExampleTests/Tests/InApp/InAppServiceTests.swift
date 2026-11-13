//
//  InAppServiceTests.swift
//  RetenoExampleTests
//
//  Created by Oleh Mytsovda on 31.01.2024.
//  Copyright © 2024 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class InAppServiceTests: XCTestCase {
    
    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var storage: KeyValueStorage!
    private var sut: InAppService!
    
    override func setUp() {
        suiteName = "in-app-tests-" + UUID().uuidString
        userDefaults = UserDefaults(suiteName: suiteName)
        storage = KeyValueStorage(storage: userDefaults)
        sut = .init(
            requestService: MobileRequestService(requestManager: RequestManager.stub),
            storage: storage
        )
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        sut = nil
        clearStorage()
        userDefaults.removePersistentDomain(forName: suiteName)
        HTTPStubs.removeAllStubs()
    }

    private func clearStorage() {
        userDefaults.removeObject(forKey: StorageKeys.users.rawValue)
    }
    
    func test_getInAppMessages() {
        let eTag = "1234567890"
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: ["ETag": eTag])
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubPath = OHPathForFile("in_app_message_content.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var receivedContents: [InAppContent] = []
        var receivedShowModels: [InAppShowModel] = []
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            receivedContents = contents
            receivedShowModels = showModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertTrue(receivedContents.isNotEmpty, "contenst shouldn't be empty")
            XCTAssertTrue(receivedShowModels.isNotEmpty, "models shouldn't be empty")
            XCTAssertTrue(receivedContents.count == receivedShowModels.count, "count of values should be equel")
            XCTAssertTrue(eTag == self.storage.getValue(forKey: StorageKeys.eTag.rawValue), "eTag shoud be equal")
        }
    }
    
    func test_getInAppMessagesWithNotFailedResult() {
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var noData = true
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            noData = false
        }
        
        expectation.fulfill()
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(noData, "data shoudn't be collected")
        }
    }
    
    
    func test_getInAppMessagesFiltering() {
        let eTag = "1234567890"
        storage.addOnlyOnceDisplayedId(id: 123123123)
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages_valid.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: ["ETag": eTag])
        }
        
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubPath = OHPathForFile("in_app_contents_valid.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        let expectation = expectation(description: "Request")
        var receivedContents: [InAppContent] = []
        var receivedShowModels: [InAppShowModel] = []
        sut.getInAppMessages()
        sut.inAppContents = { contents, showModels in
            receivedContents = contents
            receivedShowModels = showModels
            expectation.fulfill()
        }
        
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertTrue(receivedShowModels.count == 1)
            XCTAssertTrue(receivedContents.count == 1)
            XCTAssertTrue(receivedShowModels.count == receivedContents.count, "should be same count of elements")
            XCTAssertTrue(eTag == self.storage.getValue(forKey: StorageKeys.eTag.rawValue), "eTag shoud be equal")
        }
    }
}


extension InAppServiceTests {
    private var firstIID: String { "11111111-1111-4111-8111-111111111111" }
    private var secondIID: String { "22222222-2222-4222-8222-222222222222" }

    private func deliveryMessage(iid: String, deadline: Date, targeting: [String: Any]? = nil) -> [String: Any] {
        ["messageId": 70, "messageInstanceId": 80, "priority": 20, "iid": iid,
         "expiresAt": DeliveryDate.format(deadline), "displayRules": [
            "FREQUENCY": ["enabled": true, "type": "FREQUENCY", "predicates": [["name": "ONCE_PER_APP", "isActive": true]]],
            "ASYNC": ["IS_IN_SEGMENT": ["enabled": false]],
            "TARGETING": targeting ?? ["enabled": false, "type": "TARGETING"],
            "SCHEDULE": ["enabled": false, "predicates": []]
         ]]
    }

    private func deliveryContent(iid: String, name: String) -> [String: Any] {
        ["iid": iid, "messageInstanceId": 80, "layoutType": "FULL",
         "model": ["title": "${name}", "nullable": NSNull(), "items": [NSNull(), "item"]],
         "personalisation": ["name": name, "nullable": NSNull()]]
    }

    func test_delivery_same_snapshot_is_authorized_independently_and_failed_survives_reopen_and_ack() throws {
        let now = Date()
        let entries = [deliveryMessage(iid: firstIID, deadline: now.addingTimeInterval(3600)),
                       deliveryMessage(iid: secondIID, deadline: now.addingTimeInterval(3600))]
        storage.addOnlyOnceDisplayedId(id: 70)
        var contentIIDs: [String] = []
        stub(condition: pathEndsWith("v1/inapp/messages")) { request in
            let query = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)?.queryItems
            XCTAssertNil(query?.first(where: { $0.name == "includeWorkflow" }))
            return HTTPStubsResponse(jsonObject: ["messages": entries], statusCode: 200, headers: ["ETag": "delivery"])
        }
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { request in
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! [String: Any]
            XCTAssertNil(body["messageInstanceIds"])
            let messages = body["messages"] as! [[String: Any]]
            let iid = messages[0]["iid"] as! String
            contentIIDs.append(iid)
            return HTTPStubsResponse(jsonObject: ["contents": [self.deliveryContent(iid: iid, name: iid == self.firstIID ? "Alice" : "Bob")]], statusCode: 200, headers: nil)
        }
        let discovery = expectation(description: "Discovery")
        var models: [InAppShowModel] = []
        sut.inAppContents = { contents, showModels in
            XCTAssertTrue(contents.isEmpty)
            models = showModels
            discovery.fulfill()
        }
        sut.getInAppMessages()
        wait(for: [discovery], timeout: 2)
        XCTAssertEqual(models.count, 2)
        XCTAssertTrue(contentIIDs.isEmpty, "Content waits for display conditions")
        let content = expectation(description: "Execution content")
        content.expectedFulfillmentCount = 2
        var authorized: [InAppContent] = []
        for model in models {
            sut.authorizeDelivery(model.message) { value in
                if let value { authorized.append(value) }
                content.fulfill()
            }
        }
        wait(for: [content], timeout: 2)
        XCTAssertEqual(Set(contentIIDs), [firstIID, secondIID])
        XCTAssertEqual(authorized.count, 2)
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: Date()).isEmpty)
        let first = try XCTUnwrap(authorized.first { $0.iid == firstIID })
        let second = try XCTUnwrap(authorized.first { $0.iid == secondIID })
        XCTAssertNotEqual(first.personalisation, second.personalisation)
        let raw = try JSONSerialization.jsonObject(with: first.model.data(using: .utf8)!) as! [String: Any]
        XCTAssertTrue(raw["nullable"] is NSNull)
        XCTAssertTrue((raw["items"] as! [Any])[0] is NSNull)
        sut.sendInteraction(with: first, status: .failed)
        XCTAssertTrue(storage.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        sut.sendInteraction(with: first)
        sut.sendInteraction(with: first)
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suiteName))
        XCTAssertTrue(reopened.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertFalse(reopened.hasShownDelivery(iid: secondIID, context: DeliveryContext.current))
        let queued = reopened.pendingDeliveryInteractions(context: DeliveryContext.current, now: Date())
        XCTAssertEqual(queued.count, 1, "Terminal FAILED prevents subsequent OPENED observations")
        let failed = try XCTUnwrap(queued.first { $0.interaction.status == .failed })
        XCTAssertEqual(failed.interaction.id, firstIID)
        XCTAssertEqual(failed.interaction.toJSON()["serverAssignedIid"] as? Bool, true)
        let eventTime = try XCTUnwrap(failed.interaction.toJSON()["time"] as? String)
        XCTAssertTrue(eventTime.hasSuffix("Z"))
        XCTAssertFalse(eventTime.contains("."))
        reopened.completeDeliveryInteraction(id: failed.id, retryAt: nil)
        XCTAssertTrue(reopened.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertFalse(sut.canPresentDelivery(first))
        XCTAssertTrue(sut.canPresentDelivery(second))
        XCTAssertEqual(reopened.getOnlyOnceDisplayedInAppIds(), [70])
    }

    func test_early_delivery_click_keeps_visibility_opened_and_its_persistent_suppression() throws {
        let clock = Date()
        sut = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage, now: { clock })
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [self.deliveryMessage(iid: self.firstIID,
                deadline: clock.addingTimeInterval(3600))]], statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            HTTPStubsResponse(jsonObject: ["contents": [self.deliveryContent(iid: self.firstIID, name: "Alice")]],
                              statusCode: 200, headers: nil)
        }
        let discovered = expectation(description: "Discovery")
        var message: Message?
        sut.inAppContents = { _, models in message = models.first?.message; discovered.fulfill() }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        let authorized = expectation(description: "Authorized content")
        var content: InAppContent?
        sut.authorizeDelivery(try XCTUnwrap(message)) { content = $0; authorized.fulfill() }
        wait(for: [authorized], timeout: 2)
        let shown = try XCTUnwrap(content)
        sut.sendInteraction(with: shown, status: .clicked,
                            action: .init(type: "OPEN_URL", targetComponentId: "buy", url: "https://example.com/order"))
        XCTAssertFalse(storage.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertTrue(sut.canPresentDelivery(shown), "An early click must not block actual visibility")
        sut.sendInteraction(with: shown)
        sut.sendInteraction(with: shown)
        let observations = storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: clock)
        XCTAssertEqual(observations.map { $0.interaction.status }, [.clicked, .opened])
        XCTAssertEqual(Set(observations.map { $0.interaction.id }), [firstIID])
        for observation in observations { storage.completeDeliveryInteraction(id: observation.id, retryAt: nil) }
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suiteName))
        XCTAssertTrue(reopened.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertFalse(sut.canPresentDelivery(shown), "Visibility suppression survives both acknowledgments")
    }

    func test_delivery_expiry_offline_revalidation_and_identity_switch_prevent_first_display() throws {
        var clock = Date()
        var account = "account-A"
        storage.set(value: account, forKey: StorageKeys.inAppContext.rawValue)
        sut = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage,
                           now: { clock }, context: { account })
        let deadline = clock.addingTimeInterval(60)
        let entry = deliveryMessage(iid: firstIID, deadline: deadline)
        var contentStatus: Int32 = 200
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [entry]], statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            HTTPStubsResponse(jsonObject: contentStatus == 200 ? ["contents": [self.deliveryContent(iid: self.firstIID, name: "Alice")]] : [:], statusCode: contentStatus, headers: nil)
        }
        let discovered = expectation(description: "Discovery")
        var model: InAppShowModel?
        sut.inAppContents = { _, models in model = models.first; discovered.fulfill() }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        let message = try XCTUnwrap(model?.message)
        let downloaded = expectation(description: "Authorized content")
        var authorized: InAppContent?
        sut.authorizeDelivery(message) { authorized = $0; downloaded.fulfill() }
        wait(for: [downloaded], timeout: 2)
        let cached = try XCTUnwrap(authorized)
        XCTAssertTrue(sut.canPresentDelivery(cached))
        contentStatus = 503
        let offline = expectation(description: "Revalidation failed")
        sut.authorizeDelivery(message) { XCTAssertNil($0); offline.fulfill() }
        wait(for: [offline], timeout: 2)
        clock = deadline
        XCTAssertFalse(sut.canPresentDelivery(cached))
        clock = deadline.addingTimeInterval(-1)
        account = "account-B"
        XCTAssertFalse(sut.canPresentDelivery(cached))
        sut.sendInteraction(with: cached)
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: "account-B", now: clock).isEmpty)
    }

    func test_delivery_repeated_discovery_keeps_original_deadline_and_shown_marker_after_ack() throws {
        let clock = Date()
        var deadline = clock.addingTimeInterval(60)
        sut = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage, now: { clock })
        var responseCode: Int32 = 200
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [self.deliveryMessage(iid: self.firstIID, deadline: deadline)]], statusCode: responseCode, headers: ["ETag": "same"])
        }
        let discovered = expectation(description: "Initial discovery")
        sut.inAppContents = { _, models in XCTAssertEqual(models.count, 1); discovered.fulfill() }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        var opened = NewInteraction(id: firstIID, time: clock, messageInstanceId: 80, status: .opened, statusDescription: nil)
        opened.serverAssignedIid = true
        storage.recordDeliveryInteraction(opened, context: DeliveryContext.current, now: clock)
        let event = try XCTUnwrap(storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: clock).first)
        storage.completeDeliveryInteraction(id: event.id, retryAt: nil)
        deadline = deadline.addingTimeInterval(3600)
        for status in [Int32(200), Int32(304)] {
            responseCode = status
            let refreshed = expectation(description: "Repeated discovery")
            sut.inAppContents = { _, models in XCTAssertTrue(models.isEmpty); refreshed.fulfill() }
            sut.getInAppMessages()
            wait(for: [refreshed], timeout: 2)
        }
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suiteName))
        XCTAssertTrue(reopened.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertEqual(reopened.getInAppMessages().first?.expiresAt, DeliveryDate.format(clock.addingTimeInterval(60)))
    }

    func test_delivery_event_and_time_conditions_run_before_content_request() throws {
        let clock = Date()
        let targeting: [String: Any] = ["enabled": true, "type": "TARGETING", "schema": [
            "exclude": ["relation": "AND", "groups": []],
            "include": ["relation": "AND", "groups": [["relation": "AND", "conditions": [
                ["operand": ["name": "USER"], "operator": "TIME_SPENT_IN_APP", "values": [["unit": "SECOND", "amount": 10]]],
                ["operand": ["name": "EVENT"], "values": [["event": "purchase", "parameters": ["relation": "AND", "values": []]]]]
            ]]]]
        ]]
        let entry = deliveryMessage(iid: firstIID, deadline: clock.addingTimeInterval(3600), targeting: targeting)
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [entry]], statusCode: 200, headers: nil)
        }
        let requested = expectation(description: "Content requested after conditions")
        var contentCalls = 0
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            contentCalls += 1
            requested.fulfill()
            return HTTPStubsResponse(jsonObject: ["contents": [self.deliveryContent(iid: self.firstIID, name: "Alice")]], statusCode: 200, headers: nil)
        }
        let discovered = expectation(description: "Discovered")
        var showModel: InAppShowModel?
        sut.inAppContents = { _, models in showModel = models.first; discovered.fulfill() }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        let presenter = InAppMessagePresenter(model: try XCTUnwrap(showModel), storage: storage) { message, _ in
            self.sut.authorizeDelivery(message) { _ in }
        }
        presenter.checkEvent(eventTypeName: "purchase", parameters: [])
        presenter.updateTimeSpendInApp(time: 9)
        XCTAssertEqual(contentCalls, 0)
        presenter.updateTimeSpendInApp(time: 10)
        XCTAssertEqual(contentCalls, 0)
        presenter.checkEvent(eventTypeName: "purchase", parameters: [])
        wait(for: [requested], timeout: 2)
        XCTAssertEqual(contentCalls, 1)
    }
}

extension InAppServiceTests {
    func test_mixed_discovery_preserves_ordinary_and_valid_delivery_when_an_entry_is_malformed() throws {
        let deadline = Date().addingTimeInterval(3600)
        var ordinary = deliveryMessage(iid: firstIID, deadline: deadline)
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "expiresAt")
        ordinary["messageId"] = 71
        ordinary["messageInstanceId"] = 81
        var malformed = deliveryMessage(iid: secondIID, deadline: deadline)
        malformed["iid"] = 123
        let valid = deliveryMessage(iid: firstIID, deadline: deadline)
        var ordinaryBodies: [[String: Any]] = []
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [ordinary, malformed, valid]], statusCode: 200, headers: nil)
        }
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { request in
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! [String: Any]
            ordinaryBodies.append(body)
            return HTTPStubsResponse(jsonObject: ["contents": [["messageInstanceId": 81, "layoutType": "FULL", "model": [:]]]], statusCode: 200, headers: nil)
        }
        let discovered = expectation(description: "Mixed discovery")
        sut.inAppContents = { contents, models in
            XCTAssertEqual(contents.map { $0.messageInstanceId }, [81])
            XCTAssertEqual(models.count, 2)
            XCTAssertEqual(models.filter { $0.message.hasServerAssignedIid }.map { $0.message.iid }, [self.firstIID])
            discovered.fulfill()
        }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        XCTAssertEqual(ordinaryBodies.count, 1)
        XCTAssertNil(ordinaryBodies[0]["messages"])
        XCTAssertEqual(ordinaryBodies[0]["messageInstanceIds"] as? [Int], [81])
    }

    func test_unsupported_enabled_rule_is_deferred_across_cached_discovery() {
        let deadline = Date().addingTimeInterval(3600)
        var entry = deliveryMessage(iid: firstIID, deadline: deadline)
        var rules = entry["displayRules"] as! [String: Any]
        rules["UNKNOWN_RULE"] = ["enabled": true]
        entry["displayRules"] = rules
        var statusCode: Int32 = 200
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [entry]], statusCode: statusCode, headers: ["ETag": "rules"])
        }
        for code in [Int32(200), Int32(304)] {
            statusCode = code
            let deferred = expectation(description: "Unsupported rule deferred")
            sut.inAppContents = { contents, models in
                XCTAssertTrue(contents.isEmpty)
                XCTAssertTrue(models.isEmpty)
                deferred.fulfill()
            }
            sut.getInAppMessages()
            wait(for: [deferred], timeout: 2)
        }
    }
}


extension InAppServiceTests {
    func test_discovery_failure_completes_request_and_allows_subsequent_delivery_discovery() {
        var status: Int32 = 503
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: status == 200 ? ["messages": [self.deliveryMessage(iid: self.firstIID, deadline: Date().addingTimeInterval(60))]] : [:],
                              statusCode: status, headers: nil)
        }
        let failed = expectation(description: "Failed discovery completed")
        sut.discoveryFailed = { failed.fulfill() }
        sut.getInAppMessages()
        wait(for: [failed], timeout: 2)
        status = 200
        let recovered = expectation(description: "Delivery discovery recovered")
        sut.discoveryFailed = nil
        sut.inAppContents = { _, models in
            XCTAssertEqual(models.first?.message.iid, self.firstIID)
            recovered.fulfill()
        }
        sut.getInAppMessages()
        wait(for: [recovered], timeout: 2)
    }
}

extension InAppServiceTests {
    func test_mixed_discovery_content_failure_still_exposes_delivery_candidates_and_allows_retry() throws {
        let now = Date()
        var ordinary = deliveryMessage(iid: firstIID, deadline: now.addingTimeInterval(3600))
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "expiresAt")
        ordinary["messageId"] = 71
        ordinary["messageInstanceId"] = 81
        let delivery = deliveryMessage(iid: firstIID, deadline: now.addingTimeInterval(3600))
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [ordinary, delivery]], statusCode: 200, headers: nil)
        }
        var responseStatus: Int32 = 503
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            HTTPStubsResponse(data: Data("invalid content".utf8), statusCode: responseStatus, headers: nil)
        }
        for status in [Int32(503), Int32(200)] {
            responseStatus = status
            let eligible = expectation(description: "Delivery remains available after ordinary content failure")
            sut.inAppContents = { contents, models in
                XCTAssertTrue(contents.isEmpty)
                XCTAssertEqual(models.map { $0.message.iid }, [self.firstIID])
                eligible.fulfill()
            }
            sut.getInAppMessages()
            wait(for: [eligible], timeout: 2)
        }
    }

    func test_delivery_resume_does_not_reprocess_ordinary_and_reauthorizes_before_rendering() throws {
        var now = Date()
        let deadline = now.addingTimeInterval(60)
        sut = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage, now: { now })
        var ordinary = deliveryMessage(iid: firstIID, deadline: deadline)
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "iid")
        ordinary.removeValue(forKey: "expiresAt")
        ordinary["messageId"] = 71
        ordinary["messageInstanceId"] = 81
        let delivery = deliveryMessage(iid: firstIID, deadline: deadline)
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [ordinary, delivery]], statusCode: 200, headers: nil)
        }
        var contentRequests = 0
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { request in
            contentRequests += 1
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! [String: Any]
            let response: [[String: Any]] = body["messages"] == nil ?
                [["messageInstanceId": 81, "layoutType": "FULL", "model": [:]]] :
                [self.deliveryContent(iid: self.firstIID, name: "Alice")]
            return HTTPStubsResponse(jsonObject: ["contents": response], statusCode: 200, headers: nil)
        }
        let discovered = expectation(description: "Mixed discovery")
        sut.inAppContents = { _, models in
            XCTAssertEqual(models.count, 2)
            discovered.fulfill()
        }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        var models: [InAppShowModel] = []
        sut.deliveryShowModels = { models = $0 }
        sut.inAppContents = { _, _ in XCTFail("Delivery resume must not replay ordinary candidates") }
        sut.reprocessDeliveryMessages()
        XCTAssertEqual(models.map { $0.message.iid }, [firstIID])
        XCTAssertEqual(contentRequests, 1, "Resume waits for conditions before delivery content authorization")
        let authorized = expectation(description: "Fresh delivery authorization")
        sut.authorizeDelivery(try XCTUnwrap(models.first?.message)) { content in
            XCTAssertNotNil(content)
            authorized.fulfill()
        }
        wait(for: [authorized], timeout: 2)
        XCTAssertEqual(contentRequests, 2)
        now = deadline
        sut.reprocessDeliveryMessages()
        XCTAssertTrue(models.isEmpty, "Foreground retry keeps the original absolute deadline")
        XCTAssertEqual(contentRequests, 2)
    }
}

extension InAppServiceTests {
    func test_delivery_authorization_is_invalidated_by_changed_non_frequency_rules() throws {
        let now = Date()
        var entry = deliveryMessage(iid: firstIID, deadline: now.addingTimeInterval(3600))
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [entry]], statusCode: 200, headers: nil)
        }
        var contentRequests = 0
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            contentRequests += 1
            return HTTPStubsResponse(jsonObject: ["contents": [self.deliveryContent(iid: self.firstIID, name: "Alice")]], statusCode: 200, headers: nil)
        }
        let initial = expectation(description: "Initial rules")
        var evaluated: Message?
        sut.inAppContents = { _, models in evaluated = models.first?.message; initial.fulfill() }
        sut.getInAppMessages()
        wait(for: [initial], timeout: 2)
        let message = try XCTUnwrap(evaluated)
        let authorized = expectation(description: "Content authorized under evaluated rules")
        var content: InAppContent?
        sut.authorizeDelivery(message) { content = $0; authorized.fulfill() }
        wait(for: [authorized], timeout: 2)
        let cached = try XCTUnwrap(content)
        XCTAssertTrue(sut.canPresentDelivery(cached))
        var rules = entry["displayRules"] as! [String: Any]
        rules["FREQUENCY"] = ["enabled": false, "type": "FREQUENCY", "predicates": []]
        entry["displayRules"] = rules
        let frequencyOnly = expectation(description: "Frequency remains bypassed")
        sut.inAppContents = { _, _ in frequencyOnly.fulfill() }
        sut.getInAppMessages()
        wait(for: [frequencyOnly], timeout: 2)
        XCTAssertTrue(sut.canPresentDelivery(cached))
        rules["TARGETING"] = ["enabled": true, "type": "TARGETING", "schema": [
            "exclude": ["relation": "AND", "groups": []],
            "include": ["relation": "AND", "groups": [["relation": "AND", "conditions": [
                ["operand": ["name": "EVENT"], "values": [["event": "new-event",
                    "parameters": ["relation": "AND", "values": []]]]]
            ]]]]
        ]]
        entry["displayRules"] = rules
        let updated = expectation(description: "Changed targeting")
        sut.inAppContents = { _, _ in updated.fulfill() }
        sut.getInAppMessages()
        wait(for: [updated], timeout: 2)
        XCTAssertFalse(sut.canPresentDelivery(cached), "Authorization cannot outlive the evaluated targeting")
        let rejected = expectation(description: "Old presenter cannot authorize with stale rules")
        sut.authorizeDelivery(message) { XCTAssertNil($0); rejected.fulfill() }
        wait(for: [rejected], timeout: 2)
        XCTAssertEqual(contentRequests, 1)
        rules["TARGETING"] = ["enabled": false, "type": "TARGETING"]
        rules["ASYNC"] = ["IS_IN_SEGMENT": ["enabled": true, "segmentId": 99]]
        entry["displayRules"] = rules
        let segmentUpdated = expectation(description: "Changed async rule")
        stub(condition: pathEndsWith("v1/inapp/async-rules/check")) { _ in
            HTTPStubsResponse(jsonObject: ["checks": []], statusCode: 200, headers: nil)
        }
        sut.inAppContents = { _, _ in segmentUpdated.fulfill() }
        sut.getInAppMessages()
        wait(for: [segmentUpdated], timeout: 2)
        XCTAssertFalse(sut.canPresentDelivery(cached), "A new segment condition requires fresh evaluation")
    }

    func test_unchanged_identity_notifications_preserve_in_app_cache() throws {
        let service = MobileRequestService(requestManager: .stub)
        let session = SessionService()
        defer { session.invalidateTimer() }
        let messages = InAppMessages(mobileRequestService: service,
            inAppRequestService: InAppRequestService(requestManager: .stub), storage: storage,
            scheduler: EventsSenderScheduler(mobileRequestService: service, storage: storage), sessionService: session)
        messages.subscribeOnNotifications()
        let data = try JSONSerialization.data(withJSONObject: deliveryMessage(iid: firstIID, deadline: Date().addingTimeInterval(60)))
        let cached = try JSONDecoder().decode(Message.self, from: data)
        storage.saveInAppMessages(messages: [cached])
        storage.set(value: "existing-etag", forKey: StorageKeys.eTag.rawValue)
        NotificationCenter.default.post(name: Reteno.userUpdateInitiated, object: nil)
        NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
        let processed = expectation(description: "Identity notifications processed")
        DispatchQueue.main.async { processed.fulfill() }
        wait(for: [processed], timeout: 2)
        XCTAssertEqual(storage.getInAppMessages().first?.iid, firstIID)
        XCTAssertEqual(storage.getValue(forKey: StorageKeys.eTag.rawValue) as String?, "existing-etag")
        withExtendedLifetime(messages) {}
    }

    func test_post_write_identity_hook_blocks_duplicate_completion_until_real_registration() {
        let service = MobileRequestService(requestManager: .stub, registrationStorage: storage)
        let session = SessionService()
        defer { session.invalidateTimer() }
        let messages = InAppMessages(mobileRequestService: service,
            inAppRequestService: InAppRequestService(requestManager: .stub), storage: storage,
            scheduler: EventsSenderScheduler(mobileRequestService: service, storage: storage), sessionService: session)
        messages.subscribeOnNotifications()
        // Another service has already advanced the shared cache marker to the new context.
        storage.set(value: DeliveryContext.current, forKey: StorageKeys.inAppContext.rawValue)
        storage.set(value: "previous-etag", forKey: StorageKeys.eTag.rawValue)
        let invalidated = expectation(description: "Post-write hook completes after main-queue invalidation")
        DispatchQueue.global().async {
            messages.userIdentityDidChange(from: "previous-account")
            invalidated.fulfill()
        }
        wait(for: [invalidated], timeout: 2)
        XCTAssertNil(storage.getValue(forKey: StorageKeys.eTag.rawValue) as String?)
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        let unchanged = expectation(description: "Duplicate no-op update completed")
        NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
        messages.getInAppMessages()
        DispatchQueue.main.async { unchanged.fulfill() }
        wait(for: [unchanged], timeout: 2)
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        let discovered = expectation(description: "Discovery only after matching HTTP upsert success")
        stub(condition: pathEndsWith("v1/inapp/messages")) { request in
            XCTAssertFalse(self.storage.hasPendingDeliveryRegistration)
            XCTAssertNil(request.value(forHTTPHeaderField: "If-None-Match").flatMap { $0.isEmpty ? nil : $0 })
            discovered.fulfill()
            return HTTPStubsResponse(jsonObject: [:], statusCode: 503, headers: nil)
        }
        stub(condition: pathEndsWith("v1/device")) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        service.upsertDevice(externalUserId: RequestIdentity.current.externalUserId,
            email: ExternalUserDataHelper.getEmail(), phone: ExternalUserDataHelper.getPhone(), isSubscribedOnPush: false)
        wait(for: [discovered], timeout: 2)
        withExtendedLifetime(messages) {}
    }
}

extension InAppServiceTests {
    func test_discovery_context_change_sets_registration_barrier_before_cache_ownership_advances() {
        var account = "registered-A"
        storage.set(value: account, forKey: StorageKeys.inAppContext.rawValue)
        sut = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage, context: { account })
        storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
        account = "pending-B"
        let blocked = expectation(description: "Discovery fails closed while context changes")
        sut.discoveryFailed = { blocked.fulfill() }
        sut.getInAppMessages()
        wait(for: [blocked], timeout: 2)
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        XCTAssertFalse(storage.getValue(forKey: StorageKeys.isUpdatedDevice.rawValue) as Bool)
        XCTAssertEqual(storage.getValue(forKey: StorageKeys.inAppContext.rawValue) as String?, account)
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suiteName))
        XCTAssertTrue(reopened.hasPendingDeliveryRegistration)
        let restarted = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: reopened, context: { account })
        let stillBlocked = expectation(description: "Advanced cache marker does not imply readiness")
        restarted.discoveryFailed = { stillBlocked.fulfill() }
        restarted.getInAppMessages()
        wait(for: [stillBlocked], timeout: 2)
    }
}


extension InAppServiceTests {
    func test_priority_waits_for_higher_candidate_before_presentation() throws {
        let queue = InAppPresentationQueue()
        var lowPayload = deliveryMessage(iid: firstIID, deadline: Date().addingTimeInterval(60))
        lowPayload["priority"] = 10
        lowPayload["messageId"] = 99
        let low = try JSONDecoder().decode(Message.self, from: JSONSerialization.data(withJSONObject: lowPayload))
        let high = try JSONDecoder().decode(Message.self, from: JSONSerialization.data(
            withJSONObject: deliveryMessage(iid: secondIID, deadline: Date().addingTimeInterval(60))))
        let lowToken = try XCTUnwrap(queue.begin(low))
        let highToken = try XCTUnwrap(queue.begin(high))
        var selected: [String] = []
        let shown = expectation(description: "Higher priority wins after asynchronous eligibility")
        queue.resolve(low, token: lowToken) { selected.append("low") }
        DispatchQueue.main.async {
            XCTAssertTrue(selected.isEmpty)
            queue.resolve(high, token: highToken) {
                selected.append("high")
                shown.fulfill()
            }
        }
        wait(for: [shown], timeout: 2)
        XCTAssertEqual(selected, ["high"])
    }

    func test_priority_falls_back_when_higher_candidate_is_not_eligible() throws {
        let queue = InAppPresentationQueue()
        var lowPayload = deliveryMessage(iid: firstIID, deadline: Date().addingTimeInterval(60))
        lowPayload["priority"] = 10
        let low = try JSONDecoder().decode(Message.self, from: JSONSerialization.data(withJSONObject: lowPayload))
        let high = try JSONDecoder().decode(Message.self, from: JSONSerialization.data(
            withJSONObject: deliveryMessage(iid: secondIID, deadline: Date().addingTimeInterval(60))))
        let lowToken = try XCTUnwrap(queue.begin(low))
        let highToken = try XCTUnwrap(queue.begin(high))
        let shown = expectation(description: "Eligible lower priority candidate wins")
        queue.resolve(low, token: lowToken) { shown.fulfill() }
        queue.resolve(high, token: highToken, present: nil)
        wait(for: [shown], timeout: 2)
    }

    func test_failed_delivery_keeps_suppression_after_queue_acknowledgment() throws {
        var observation = NewInteraction(id: firstIID, time: Date(), messageInstanceId: 80,
                                         status: .failed, statusDescription: "Renderer unavailable")
        observation.serverAssignedIid = true
        storage.recordDeliveryInteraction(observation, context: "account", now: Date())
        let queued = try XCTUnwrap(storage.pendingDeliveryInteractions(context: "account", now: Date()).first)
        storage.completeDeliveryInteraction(id: queued.id, retryAt: nil)

        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suiteName))
        XCTAssertTrue(reopened.hasShownDelivery(iid: firstIID, context: "account"))
        XCTAssertTrue(reopened.pendingDeliveryInteractions(context: "account", now: Date()).isEmpty)
    }
}


extension InAppServiceTests {
    func test_pause_cancels_server_candidates_and_stale_callbacks_without_losing_ordinary_candidate() throws {
        let queue = InAppPresentationQueue()
        let server = try JSONDecoder().decode(Message.self, from: JSONSerialization.data(
            withJSONObject: deliveryMessage(iid: firstIID, deadline: Date().addingTimeInterval(3600))))
        var ordinary = server
        ordinary.iid = nil
        ordinary.expiresAt = nil
        ordinary.priority = 10
        let ordinaryToken = try XCTUnwrap(queue.begin(ordinary))
        let canceledToken = try XCTUnwrap(queue.begin(server))
        queue.resolve(server, token: canceledToken) { XCTFail("Paused server candidate must not display") }

        queue.cancelServerDeliveries()
        queue.resolve(server, token: canceledToken) { XCTFail("Late authorization must not restore a canceled candidate") }
        let postponed = expectation(description: "Ordinary candidate retains its existing pause policy")
        queue.resolve(ordinary, token: ordinaryToken) { postponed.fulfill() }
        wait(for: [postponed], timeout: 2)

        let resumedToken = try XCTUnwrap(queue.begin(server))
        queue.resolve(server, token: canceledToken) { XCTFail("An earlier pause must not overwrite resumed eligibility") }
        let resumed = expectation(description: "Same unshown IID remains eligible on resume")
        queue.resolve(server, token: resumedToken) { resumed.fulfill() }
        wait(for: [resumed], timeout: 2)
        XCTAssertFalse(storage.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
    }

    func test_canceled_authorization_cannot_block_or_reauthorize_same_iid_after_resume() throws {
        let entry = deliveryMessage(iid: firstIID, deadline: Date().addingTimeInterval(3600))
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": [entry]], statusCode: 200, headers: nil)
        }
        let discovered = expectation(description: "Received IID discovered")
        var message: Message?
        sut.inAppContents = { _, models in message = models.first?.message; discovered.fulfill() }
        sut.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        let candidate = try XCTUnwrap(message)
        var requests = 0
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            requests += 1
            return HTTPStubsResponse(jsonObject: ["contents": [self.deliveryContent(iid: self.firstIID, name: "Alice")]],
                                     statusCode: 200, headers: nil)
        }
        let canceled = expectation(description: "Pre-pause authorization returns no usable content")
        sut.authorizeDelivery(candidate) { content in
            XCTAssertNil(content)
            canceled.fulfill()
        }
        sut.cancelDeliveryAuthorizations()

        let resumed = expectation(description: "Resume freshly authorizes the same IID")
        var resumedContent: InAppContent?
        sut.authorizeDelivery(candidate) { content in
            resumedContent = content
            resumed.fulfill()
        }
        wait(for: [canceled, resumed], timeout: 2)
        XCTAssertEqual(requests, 2)
        XCTAssertTrue(sut.canPresentDelivery(try XCTUnwrap(resumedContent)))
        XCTAssertFalse(storage.hasShownDelivery(iid: firstIID, context: DeliveryContext.current))
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: Date()).isEmpty)
    }
}
