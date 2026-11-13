//
//  InAppRequestServiceTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 31.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class InAppRequestServiceTests: XCTestCase {

    private var sut: InAppRequestService!
    
    override func setUp() {
        sut = InAppRequestService(requestManager: .stub)
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
        sut = nil
    }
    
    // MARK: Fetch base HTML
    
    func test_fetchBaseHTML_withValidHeaders() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: ["x-amz-meta-version": "20230125-1501-b1c69b2"])
        }
        var expectedHeader: String?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
            switch result {
            case .success(let version):
                expectedHeader = version
                
            case .failure:
                expectedHeader = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertEqual(expectedHeader, "20230125-1501-b1c69b2", "should return valid expected version in header")
        }
    }
    
    func test_fetchBaseHTML_withEmptyHeaders() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedHeader: String?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
            switch result {
            case .success(let version):
                expectedHeader = version
                
            case .failure:
                expectedHeader = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNil(expectedHeader, "version from headers should be nil")
        }
    }
    
    func test_fetchBaseHTML_withNegativeResult() {
        stub(condition: pathEndsWith("in-app/base.latest.html")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.fetchBaseHTML { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Send script event
    
    func test_sendScriptEvent_withPositiveResult() {
        stub(condition: pathEndsWith("site-script/v1/event")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendScriptEvent(messageId: "id", data: [:]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_sendScriptEvent_withNegativeResult() {
        stub(condition: pathEndsWith("site-script/v1/event")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendScriptEvent(messageId: "id", data: [:]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }

}

extension InAppRequestServiceTests {
    func test_delivery_interaction_retry_reopens_same_body_and_retains_shown_marker_after_ack() throws {
        let suite = "delivery-retry-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let context = DeliveryContext.current
        let now = Date()
        var opened = NewInteraction(id: "11111111-1111-4111-8111-111111111111", time: now,
                                    messageInstanceId: 80, status: .opened, statusDescription: nil)
        opened.serverAssignedIid = true
        storage.recordDeliveryInteraction(opened, context: context, now: now)
        let service = MobileRequestService(requestManager: .stub)
        var requestBodies: [Data] = []
        var responseCode: Int32 = 503
        stub(condition: pathEndsWith("v1/interaction")) { request in
            requestBodies.append(request.ohhttpStubs_httpBody!)
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Device-ID"), RequestIdentity.current.deviceId)
            return HTTPStubsResponse(jsonObject: ["title": "Unavailable"], statusCode: responseCode,
                                     headers: ["Retry-After": "120"])
        }
        let initial = try XCTUnwrap(storage.pendingDeliveryInteractions(context: context, now: now).first)
        let failed = expectation(description: "Retry stored")
        let firstAttempt = SendDeliveryInteractionOperation(requestService: service, storage: storage, queued: initial)
        firstAttempt.completionBlock = { failed.fulfill() }
        let queue = OperationQueue()
        queue.addOperation(firstAttempt)
        wait(for: [failed], timeout: 2)
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: context, now: now.addingTimeInterval(119)).isEmpty)
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suite))
        let retry = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: now.addingTimeInterval(3600)).first)
        XCTAssertEqual(retry.id, initial.id)
        XCTAssertEqual(retry.interaction.time, initial.interaction.time)
        XCTAssertEqual(retry.interaction.id, initial.interaction.id)
        XCTAssertEqual(retry.attempts, 1)
        // Advance the saved next-attempt deadline explicitly; no background timer or sleep.
        reopened.completeDeliveryInteraction(id: retry.id, retryAt: now.addingTimeInterval(-1))
        let ready = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: Date()).first)
        responseCode = 200
        let acknowledged = expectation(description: "Acknowledged")
        let secondAttempt = SendDeliveryInteractionOperation(requestService: service, storage: reopened, queued: ready)
        secondAttempt.completionBlock = { acknowledged.fulfill() }
        queue.addOperation(secondAttempt)
        wait(for: [acknowledged], timeout: 2)
        XCTAssertEqual(requestBodies.count, 2)
        let firstBody = try JSONSerialization.jsonObject(with: requestBodies[0]) as! NSDictionary
        let secondBody = try JSONSerialization.jsonObject(with: requestBodies[1]) as! NSDictionary
        XCTAssertEqual(firstBody, secondBody)
        XCTAssertEqual(firstBody["serverAssignedIid"] as? Bool, true)
        XCTAssertNil(firstBody["eventId"])
        XCTAssertTrue(reopened.pendingDeliveryInteractions(context: context, now: Date()).isEmpty)
        XCTAssertTrue(reopened.hasShownDelivery(iid: opened.id, context: context))
    }

    func test_delivery_queue_preserves_multiple_observations_and_skips_other_context() throws {
        let suite = "delivery-context-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let now = Date()
        let firstIID = "11111111-1111-4111-8111-111111111111"
        let secondIID = "22222222-2222-4222-8222-222222222222"
        for (iid, status) in [(firstIID, NewInteractionStatus.opened), (firstIID, .failed), (firstIID, .clicked), (secondIID, .opened)] {
            var interaction = NewInteraction(id: iid, time: now, messageInstanceId: 80,
                                             status: status, statusDescription: nil,
                                             action: status == .clicked ? .init(type: "CLICK", targetComponentId: "button") : nil)
            interaction.serverAssignedIid = true
            storage.recordDeliveryInteraction(interaction, context: "previous-account", now: now)
        }
        XCTAssertEqual(storage.pendingDeliveryInteractions(context: "previous-account", now: now).count, 4)
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: DeliveryContext.current, now: now).isEmpty)
        let request = expectation(description: "No network call for previous context")
        request.isInverted = true
        stub(condition: pathEndsWith("v1/interaction")) { _ in
            request.fulfill()
            return HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        let observation = try XCTUnwrap(storage.pendingDeliveryInteractions(context: "previous-account", now: now).first)
        let operation = SendDeliveryInteractionOperation(requestService: MobileRequestService(requestManager: .stub),
                                                       storage: storage, queued: observation)
        let finished = expectation(description: "Skipped")
        operation.completionBlock = { finished.fulfill() }
        OperationQueue().addOperation(operation)
        wait(for: [finished], timeout: 2)
        wait(for: [request], timeout: 0.1)
        XCTAssertEqual(storage.pendingDeliveryInteractions(context: "previous-account", now: now).count, 4)
    }

    func test_delivery_terminal_response_removes_observation_without_removing_shown_state() throws {
        let suite = "delivery-terminal-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let now = Date()
        let context = DeliveryContext.current
        var interaction = NewInteraction(id: "11111111-1111-4111-8111-111111111111", time: now,
                                         messageInstanceId: 80, status: .opened, statusDescription: nil)
        interaction.serverAssignedIid = true
        storage.recordDeliveryInteraction(interaction, context: context, now: now)
        stub(condition: pathEndsWith("v1/interaction")) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 410, headers: nil)
        }
        let completed = expectation(description: "Terminal response")
        let queued = try XCTUnwrap(storage.pendingDeliveryInteractions(context: context, now: now).first)
        let operation = SendDeliveryInteractionOperation(requestService: MobileRequestService(requestManager: .stub),
                                                       storage: storage, queued: queued)
        operation.completionBlock = { completed.fulfill() }
        let queue = OperationQueue()
        queue.addOperation(operation)
        wait(for: [completed], timeout: 2)
        XCTAssertTrue(storage.pendingDeliveryInteractions(context: context, now: Date()).isEmpty)
        XCTAssertTrue(storage.hasShownDelivery(iid: interaction.id, context: context))
    }
}

extension InAppRequestServiceTests {
    func test_delivery_clicked_preserves_complete_action_and_time_through_failure_reopen_and_retry() throws {
        let suite = "delivery-clicked-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let now = Date()
        let context = DeliveryContext.current
        let requestService = MobileRequestService(requestManager: .stub)
        let service = InAppService(requestService: requestService, storage: storage, now: { now })
        let iid = "11111111-1111-4111-8111-111111111111"
        let data = try JSONSerialization.data(withJSONObject: ["iid": iid, "messageInstanceId": 80,
                                                               "layoutType": "FULL", "model": [:]])
        var content = try JSONDecoder().decode(InAppContent.self, from: data)
        content.deliveryContext = context
        let action = NotificationStatus.Action(type: "OPEN_URL", targetComponentId: "buy-button",
                                               url: "https://example.com/personalized-offer")
        service.sendInteraction(with: content, status: .clicked, action: action)
        XCTAssertFalse(storage.hasShownDelivery(iid: iid, context: context))
        XCTAssertTrue(storage.getNotificationStatuses().isEmpty, "Clicks retain their context-scoped persisted queue")
        let queued = try XCTUnwrap(storage.pendingDeliveryInteractions(context: context, now: now).first)
        var responseCode: Int32 = 503
        var bodies: [NSDictionary] = []
        stub(condition: pathEndsWith("v1/interactions/\(iid)/status")) { request in
            XCTAssertEqual(request.httpMethod, "PUT")
            XCTAssertFalse(storage.hasShownDelivery(iid: iid, context: context), "An early click must not prevent visibility OPENED")
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! NSDictionary
            bodies.append(body)
            return HTTPStubsResponse(jsonObject: [:], statusCode: responseCode, headers: nil)
        }
        let failed = expectation(description: "Failed request keeps the click")
        let firstAttempt = SendDeliveryInteractionOperation(requestService: requestService, storage: storage, queued: queued)
        firstAttempt.completionBlock = { failed.fulfill() }
        let queue = OperationQueue()
        queue.addOperation(firstAttempt)
        wait(for: [failed], timeout: 2)
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suite))
        let retry = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: now.addingTimeInterval(3600)).first)
        XCTAssertEqual(retry.interaction.status, .clicked)
        XCTAssertEqual(retry.interaction.action?.type, action.type)
        XCTAssertEqual(retry.interaction.action?.targetComponentId, action.targetComponentId)
        XCTAssertEqual(retry.interaction.action?.url, action.url)
        reopened.completeDeliveryInteraction(id: retry.id, retryAt: now.addingTimeInterval(-1))
        let ready = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: Date()).first)
        responseCode = 200
        let acknowledged = expectation(description: "Retry acknowledged")
        let secondAttempt = SendDeliveryInteractionOperation(requestService: requestService, storage: reopened, queued: ready)
        secondAttempt.completionBlock = { acknowledged.fulfill() }
        queue.addOperation(secondAttempt)
        wait(for: [acknowledged], timeout: 2)
        XCTAssertEqual(bodies.count, 2)
        XCTAssertEqual(bodies[0], bodies[1])
        XCTAssertEqual(bodies[0]["status"] as? String, "CLICKED")
        XCTAssertNil(bodies[0]["iid"])
        XCTAssertEqual(bodies[0]["time"] as? String, DateFormatter.baseBEDateFormatter.string(from: now))
        XCTAssertNil(bodies[0]["messageInstanceId"])
        XCTAssertNil(bodies[0]["serverAssignedIid"])
        XCTAssertNil(bodies[0]["eventId"])
        XCTAssertEqual(bodies[0]["action"] as? NSDictionary,
                       ["type": "OPEN_URL", "targetComponentId": "buy-button",
                        "url": "https://example.com/personalized-offer"] as NSDictionary)
        XCTAssertTrue(reopened.pendingDeliveryInteractions(context: context, now: Date()).isEmpty)
        XCTAssertFalse(reopened.hasShownDelivery(iid: iid, context: context))
    }
}

extension InAppRequestServiceTests {
    func test_click_uses_verified_context_headers_and_refuses_replay_after_account_switch() throws {
        for serverAssigned in [false, true] {
            let accountA = DeliveryContext.Snapshot(apiKey: "application-A",
                identity: RequestIdentity(deviceId: "device-A", externalUserId: "account-A"), email: nil, phone: nil)
            let accountB = DeliveryContext.Snapshot(apiKey: "application-B",
                identity: RequestIdentity(deviceId: "device-B", externalUserId: "account-B"), email: nil, phone: nil)
            var nextSnapshot = accountA
            let service = MobileRequestService(deliveryContext: {
                let captured = nextSnapshot
                nextSnapshot = accountB
                return captured
            })
            var click = NewInteraction(time: Date(), messageInstanceId: 80, status: .clicked,
                                       statusDescription: nil, action: .init(type: "CLICK", targetComponentId: "buy"))
            click.serverAssignedIid = serverAssigned
            let queued = QueuedInAppInteraction(id: UUID().uuidString, context: accountA.id,
                                                 interaction: click, nextAttempt: Date())
            var requests = 0
            stub(condition: { _ in true }) { request in
                requests += 1
                XCTAssertEqual(request.httpMethod, "PUT")
                XCTAssertEqual(request.url?.host, "api.reteno.com")
                XCTAssertTrue(request.url!.path.hasSuffix("v1/interactions/\(click.id)/status"))
                XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Access-Key"), "application-A")
                XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Device-ID"), "device-A")
                let authorization = "Basic " + Data("username:application-A".utf8).base64EncodedString()
                XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), authorization)
                return HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
            }
            let sent = expectation(description: "Click sent with verified account")
            service.sendDeliveryInteraction(queued) { result, _ in
                if case .failure = result { XCTFail("Account A owns the click") }
                sent.fulfill()
            }
            wait(for: [sent], timeout: 2)
            let skipped = expectation(description: "Account switch rejects queued click")
            service.sendDeliveryInteraction(queued) { result, _ in
                if case .success = result { XCTFail("Account B must not replay account A's click") }
                skipped.fulfill()
            }
            wait(for: [skipped], timeout: 2)
            XCTAssertEqual(requests, 1)
            HTTPStubs.removeAllStubs()
        }
    }

    func test_delivery_retry_uses_headers_from_the_same_context_snapshot_it_verified() throws {
        let accountA = DeliveryContext.Snapshot(apiKey: "application-A",
            identity: RequestIdentity(deviceId: "device-A", externalUserId: "account-A"), email: nil, phone: nil)
        let accountB = DeliveryContext.Snapshot(apiKey: "application-B",
            identity: RequestIdentity(deviceId: "device-B", externalUserId: "account-B"), email: nil, phone: nil)
        var nextSnapshot = accountA
        let service = MobileRequestService(deliveryContext: {
            let captured = nextSnapshot
            nextSnapshot = accountB
            return captured
        })
        var interaction = NewInteraction(id: "11111111-1111-4111-8111-111111111111", time: Date(),
                                         messageInstanceId: 80, status: .opened, statusDescription: nil)
        interaction.serverAssignedIid = true
        let queued = QueuedInAppInteraction(id: UUID().uuidString, context: accountA.id,
                                             interaction: interaction, nextAttempt: Date())
        stub(condition: pathEndsWith("v1/interaction")) { request in
            XCTAssertEqual(request.url?.host, "mobile-api.reteno.com")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Access-Key"), "application-A")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Device-ID"), "device-A")
            return HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        let sent = expectation(description: "Sent with the verified account")
        service.sendDeliveryInteraction(queued) { result, _ in
            if case .failure = result { XCTFail("The captured account owns the queued event") }
            sent.fulfill()
        }
        wait(for: [sent], timeout: 2)
        let skipped = expectation(description: "Next account cannot send the previous observation")
        service.sendDeliveryInteraction(queued) { result, _ in
            if case .success = result { XCTFail("Account B must not replay account A's event") }
            skipped.fulfill()
        }
        wait(for: [skipped], timeout: 2)
    }


}

extension InAppRequestServiceTests {
    func test_pending_contact_registration_survives_no_op_completion_old_ack_and_restart_until_matching_ack() throws {
        let suite = "delivery-registration-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let identityA = RequestIdentity(deviceId: "same-device", externalUserId: "account-A")
        let identityB = RequestIdentity(deviceId: "same-device", externalUserId: "account-B")
        let contextB = DeliveryContext.Snapshot(apiKey: "application", identity: identityB, email: nil, phone: nil)
        let serviceB = MobileRequestService(requestManager: .stub, identity: { identityB },
                                            deliveryContext: { contextB }, registrationStorage: storage)
        let inApps = InAppService(requestService: serviceB, storage: storage, context: { contextB.id })
        storage.beginDeliveryRegistration(context: contextB.id)
        var discoveries = 0
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            discoveries += 1
            return HTTPStubsResponse(jsonObject: ["messages": []], statusCode: 200, headers: nil)
        }
        var failCurrentUpsert = true
        stub(condition: pathEndsWith("v1/device")) { request in
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! [String: Any]
            XCTAssertEqual(body["deviceId"] as? String, "same-device")
            XCTAssertEqual(request.value(forHTTPHeaderField: "X-Reteno-Device-ID"), "same-device")
            let status: Int32 = body["externalUserId"] as? String == "account-B" && failCurrentUpsert ? 503 : 200
            return HTTPStubsResponse(jsonObject: [:], statusCode: status, headers: nil)
        }
        let failed = expectation(description: "Pending B registration fails")
        serviceB.upsertDevice(externalUserId: "account-B", email: nil, phone: nil, isSubscribedOnPush: false) { _ in
            failed.fulfill()
        }
        // The duplicate B no-op completes while B's asynchronous upsert has no acknowledgment.
        NotificationCenter.default.post(name: Reteno.userUpdateCompleted, object: nil)
        inApps.getInAppMessages()
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        XCTAssertEqual(discoveries, 0)
        wait(for: [failed], timeout: 2)
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        let old = MobileRequestService(requestManager: .stub, identity: { identityA },
                                      deliveryContext: { contextB }, registrationStorage: storage)
        let oldAcknowledged = expectation(description: "Late account A upsert acknowledged")
        old.upsertDevice(externalUserId: "account-A", email: nil, phone: nil, isSubscribedOnPush: false) { _ in
            oldAcknowledged.fulfill()
        }
        wait(for: [oldAcknowledged], timeout: 2)
        XCTAssertTrue(storage.hasPendingDeliveryRegistration, "A's success cannot release pending B")
        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suite))
        XCTAssertTrue(reopened.hasPendingDeliveryRegistration)
        let reopenedService = MobileRequestService(requestManager: .stub, identity: { identityB },
                                                   deliveryContext: { contextB }, registrationStorage: reopened)
        let restarted = InAppService(requestService: reopenedService, storage: reopened, context: { contextB.id })
        restarted.getInAppMessages()
        XCTAssertEqual(discoveries, 0, "Restart cannot bypass the pending registration")
        failCurrentUpsert = false
        let registered = expectation(description: "Current B identity acknowledged")
        reopenedService.upsertDevice(externalUserId: "account-B", email: nil, phone: nil, isSubscribedOnPush: false) { _ in
            registered.fulfill()
        }
        wait(for: [registered], timeout: 2)
        XCTAssertFalse(reopened.hasPendingDeliveryRegistration, "The HTTP boundary persists readiness without a UI observer")
        let discovered = expectation(description: "Current account discovery released")
        restarted.inAppContents = { _, _ in discovered.fulfill() }
        restarted.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        XCTAssertEqual(discoveries, 1)
    }
}

extension InAppRequestServiceTests {
    func test_scheduler_recovers_pending_contact_after_real_old_device_operation_sets_legacy_updated_flag() throws {
        let suite = "delivery-old-device-ack-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let currentIdentity = RequestIdentity.current
        let currentContext = DeliveryContext.capture()
        let oldExternalId = "old-contact-" + UUID().uuidString
        var observedContext = DeliveryContext.Snapshot(
            apiKey: currentContext.headers["X-Reteno-Access-Key"] ?? "",
            identity: RequestIdentity(deviceId: currentIdentity.deviceId, externalUserId: oldExternalId),
            email: nil, phone: nil)
        let service = MobileRequestService(requestManager: .stub, identity: { currentIdentity },
            deliveryContext: { observedContext }, registrationStorage: storage)
        let recovered = expectation(forNotification: Reteno.inAppDeviceRegistrationConfirmed, object: nil) {
            $0.userInfo?["context"] as? String == currentContext.id
        }
        stub(condition: pathEndsWith("v1/device")) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        // SendDeviceOperation also invokes the SDK's normal discovery hook after success.
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 503, headers: nil)
        }
        let oldFinished = expectation(description: "Old same-device registration acknowledged late")
        let oldOperation = SendDeviceOperation(requestService: service, storage: storage,
            device: Device(externalUserId: oldExternalId, phone: nil, email: nil, isSubscribedOnPush: false),
            identity: currentIdentity, date: Date())
        oldOperation.completionBlock = { oldFinished.fulfill() }
        oldOperation.start()
        // The old request is already constructed, but its main-queue completion has not run.
        observedContext = currentContext
        storage.beginDeliveryRegistration(context: currentContext.id)
        storage.set(value: false, forKey: StorageKeys.isUpdatedDevice.rawValue)
        wait(for: [oldFinished], timeout: 2)
        XCTAssertTrue(storage.getValue(forKey: StorageKeys.isUpdatedDevice.rawValue) as Bool,
                      "The real old operation reproduces the legacy acknowledgment race")
        XCTAssertTrue(storage.hasPendingDeliveryRegistration)
        let wasInitialized = Reteno.sdkStateHelper.isInitialized
        Reteno.sdkStateHelper.set(isInitialized: true)
        defer { Reteno.sdkStateHelper.set(isInitialized: wasInitialized) }
        let scheduler = EventsSenderScheduler(mobileRequestService: service, storage: storage)
        scheduler.forcePushEvents()
        wait(for: [recovered], timeout: 2)
        XCTAssertFalse(storage.hasPendingDeliveryRegistration,
                       "Pending context forces a fresh current-device upsert despite the legacy true flag")
        withExtendedLifetime(scheduler) {}
    }
}

extension InAppRequestServiceTests {
    func test_email_identity_change_needs_only_one_matching_upsert_without_intermediate_discovery() throws {
        let suite = "delivery-single-registration-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let identity = RequestIdentity(deviceId: "same-device", externalUserId: nil)
        let contextA = DeliveryContext.Snapshot(apiKey: "application", identity: identity, email: "a@example.com", phone: nil)
        let contextB = DeliveryContext.Snapshot(apiKey: "application", identity: identity, email: "b@example.com", phone: nil)
        var currentContext = contextA
        let service = MobileRequestService(requestManager: .stub, identity: { identity },
            deliveryContext: { currentContext }, registrationStorage: storage)
        let inApps = InAppService(requestService: service, storage: storage, context: { currentContext.id })
        currentContext = contextB
        // This is the existing service boundary invoked by the synchronous post-write hook.
        inApps.clearInApps()
        storage.set(value: contextB.id, forKey: StorageKeys.inAppContext.rawValue)
        storage.beginDeliveryRegistration(context: contextB.id)
        var upserts = 0
        stub(condition: pathEndsWith("v1/device")) { request in
            upserts += 1
            let body = try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! [String: Any]
            XCTAssertEqual(body["email"] as? String, "b@example.com")
            return HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        let registered = expectation(description: "One current email registration acknowledged")
        service.upsertDevice(email: "b@example.com", phone: nil, isSubscribedOnPush: false) { _ in
            registered.fulfill()
        }
        wait(for: [registered], timeout: 2)
        XCTAssertFalse(storage.hasPendingDeliveryRegistration)
        let discovered = expectation(description: "First discovery after the acknowledgment")
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            HTTPStubsResponse(jsonObject: ["messages": []], statusCode: 200, headers: nil)
        }
        inApps.inAppContents = { _, _ in discovered.fulfill() }
        inApps.getInAppMessages()
        wait(for: [discovered], timeout: 2)
        XCTAssertFalse(storage.hasPendingDeliveryRegistration,
                       "Clearing the old in-memory owner must not re-establish a barrier after B was acknowledged")
        XCTAssertEqual(upserts, 1)
    }
}


extension InAppRequestServiceTests {
    func test_ordinary_click_retries_original_body_after_failure_and_reopen() throws {
        let suite = "ordinary-click-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let now = Date()
        let context = DeliveryContext.current
        let requestService = MobileRequestService(requestManager: .stub)
        let service = InAppService(requestService: requestService, storage: storage, now: { now })
        let content = try JSONDecoder().decode(InAppContent.self, from: JSONSerialization.data(
            withJSONObject: ["messageInstanceId": 80, "layoutType": "FULL", "model": [:]]))
        let iid = "11111111-1111-4111-8111-111111111111"
        let action = NotificationStatus.Action(type: "OPEN_URL", targetComponentId: "buy", url: "https://example.org/order")
        var responseCode: Int32 = 503
        var bodies: [NSDictionary] = []
        stub(condition: pathEndsWith("v1/interactions/\(iid)/status")) { request in
            XCTAssertEqual(request.httpMethod, "PUT")
            bodies.append(try! JSONSerialization.jsonObject(with: request.ohhttpStubs_httpBody!) as! NSDictionary)
            return HTTPStubsResponse(jsonObject: [:], statusCode: responseCode, headers: nil)
        }

        service.sendInteraction(with: content, interactionId: iid, status: .clicked, action: action)

        let queued = try XCTUnwrap(storage.pendingDeliveryInteractions(context: context, now: now).first)
        XCTAssertEqual(queued.interaction.time, now)
        XCTAssertFalse(storage.hasShownDelivery(iid: iid, context: context))
        XCTAssertTrue(storage.getNotificationStatuses().isEmpty)
        let failed = expectation(description: "Ordinary click retained after network failure")
        let firstAttempt = SendDeliveryInteractionOperation(requestService: requestService, storage: storage, queued: queued)
        firstAttempt.completionBlock = { failed.fulfill() }
        let queue = OperationQueue()
        queue.addOperation(firstAttempt)
        wait(for: [failed], timeout: 2)

        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suite))
        let retry = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: now.addingTimeInterval(3600)).first)
        XCTAssertEqual(retry.interaction.id, iid)
        XCTAssertEqual(retry.interaction.time, now)
        XCTAssertEqual(retry.attempts, 1)
        XCTAssertNil(retry.interaction.serverAssignedIid)
        reopened.completeDeliveryInteraction(id: retry.id, retryAt: now.addingTimeInterval(-1))
        let ready = try XCTUnwrap(reopened.pendingDeliveryInteractions(context: context, now: Date()).first)
        responseCode = 200
        let acknowledged = expectation(description: "Retried ordinary click acknowledged")
        let secondAttempt = SendDeliveryInteractionOperation(requestService: requestService, storage: reopened, queued: ready)
        secondAttempt.completionBlock = { acknowledged.fulfill() }
        queue.addOperation(secondAttempt)
        wait(for: [acknowledged], timeout: 2)

        XCTAssertEqual(bodies.count, 2)
        XCTAssertEqual(bodies.first, bodies.last)
        let body = try XCTUnwrap(bodies.first)
        XCTAssertNil(body["iid"])
        XCTAssertNil(body["messageInstanceId"])
        XCTAssertEqual(body["status"] as? String, "CLICKED")
        XCTAssertEqual(body["time"] as? String, DateFormatter.baseBEDateFormatter.string(from: now))
        XCTAssertNil(body["serverAssignedIid"])
        XCTAssertEqual(body["action"] as? NSDictionary,
                       ["type": "OPEN_URL", "targetComponentId": "buy", "url": "https://example.org/order"] as NSDictionary)
        XCTAssertTrue(reopened.pendingDeliveryInteractions(context: context, now: Date()).isEmpty)
        XCTAssertFalse(reopened.hasShownDelivery(iid: iid, context: context))
    }

    func test_ordinary_click_queue_preserves_repeats_and_captured_account_without_server_suppression() throws {
        let suite = "ordinary-repeat-" + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let storage = KeyValueStorage(storage: defaults)
        let now = Date()
        let context = "previous-account"
        let service = InAppService(requestService: MobileRequestService(requestManager: .stub), storage: storage,
                                   now: { now }, context: { context })
        let content = try JSONDecoder().decode(InAppContent.self, from: JSONSerialization.data(
            withJSONObject: ["messageInstanceId": 80, "layoutType": "FULL", "model": [:]]))
        let iid = UUID().uuidString
        let action = NotificationStatus.Action(type: "CLICK", targetComponentId: "buy")
        service.sendInteraction(with: content, interactionId: iid, status: .clicked, action: action)
        service.sendInteraction(with: content, interactionId: iid, status: .clicked, action: action)
        var legacy = NewInteraction(id: iid, time: now, messageInstanceId: 80, status: .clicked,
                                    statusDescription: nil, action: action)
        legacy.serverAssignedIid = false
        storage.recordDeliveryInteraction(legacy, context: context, now: now)

        let reopened = KeyValueStorage(storage: UserDefaults(suiteName: suite))
        let observations = reopened.pendingDeliveryInteractions(context: context, now: now)
        XCTAssertEqual(observations.count, 3)
        XCTAssertEqual(Set(observations.map { $0.id }).count, 3)
        XCTAssertFalse(reopened.hasShownDelivery(iid: iid, context: context))
        XCTAssertTrue(reopened.pendingDeliveryInteractions(context: DeliveryContext.current, now: now).isEmpty)
        let skipped = expectation(description: "Old account click never sends under current credentials")
        stub(condition: { _ in true }) { _ in
            XCTFail("An ordinary click must retain its captured account")
            return HTTPStubsResponse(jsonObject: [:], statusCode: 200, headers: nil)
        }
        let operation = SendDeliveryInteractionOperation(requestService: MobileRequestService(requestManager: .stub),
                                                       storage: reopened, queued: try XCTUnwrap(observations.first))
        operation.completionBlock = { skipped.fulfill() }
        OperationQueue().addOperation(operation)
        wait(for: [skipped], timeout: 2)
        XCTAssertEqual(reopened.pendingDeliveryInteractions(context: context, now: now).count, 3)
    }
}
