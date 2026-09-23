//
//  SchedulerHardeningTests.swift
//  RetenoExampleTests
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import RetenoExample
@testable import Reteno

/// Covers the paths that keep a sync from either resending a payload or wedging the scheduler.
final class SchedulerHardeningTests: XCTestCase {

    private var sut: EventsSenderScheduler!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()

        userDefaults = UserDefaults(suiteName: "unit_tests_scheduler_hardening")
        storage = KeyValueStorage(storage: userDefaults)
        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        storage.set(value: true, forKey: StorageKeys.isUpdatedDevice.rawValue)
        sut = EventsSenderScheduler(
            mobileRequestService: MobileRequestService(requestManager: .stub),
            storage: storage,
            sendingService: SendingServiceBuilder.build()
        )
    }

    override func tearDown() {
        StorageKeys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue) }
        userDefaults.removeSuite(named: "unit_tests_scheduler_hardening")
        sut = nil
        storage = nil
        userDefaults = nil
        HTTPStubs.removeAllStubs()

        super.tearDown()
    }

    /// `prepareOperationSequence` asks for a device upsert on every sync until the backend confirms
    /// one, so a failing device request used to add one more operation per sync forever.
    ///
    /// Note that this only reproduced below iOS 18, where the deduplication used to be skipped, so
    /// on a current simulator this test guards the behaviour rather than demonstrating the fix.
    func test_repeatedUpsertOfTheSameDevice_whileRequestIsInFlight_sendsOneRequest() {
        Reteno.sdkStateHelper.set(isInitialized: true)
        defer { Reteno.sdkStateHelper.set(isInitialized: false) }

        /// Schedulers built by other test cases stay subscribed to app notifications and send their
        /// own device requests, so the count has to be scoped to this run's external user id.
        let externalUserId = "dedup_\(UUID().uuidString)"
        let lock = NSLock()
        var requestCount = 0
        stub(condition: isHost("test.host") && pathEndsWith("v1/device")) { request in
            let body = request.ohhttpStubs_httpBody ?? Data()
            let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
            if json?["externalUserId"] as? String == externalUserId {
                lock.lock()
                requestCount += 1
                lock.unlock()
            }

            return HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil).responseTime(1.0)
        }

        let device = Device(externalUserId: externalUserId, phone: nil, email: nil, isSubscribedOnPush: true)
        (0..<5).forEach { _ in sut.upsertDevice(device) }
        wait(seconds: 2.5)

        lock.lock()
        let recordedRequestCount = requestCount
        lock.unlock()
        XCTAssertEqual(recordedRequestCount, 1, "an identical pending device upsert shouldn't be enqueued again")
    }

    /// A completion handler that never runs leaves its `NetworkOperation` executing and blocks the
    /// serial queue for the rest of the process, so the manager must not drop it when it goes away.
    func test_requestManager_deallocatedBeforeResponse_stillCallsCompletion() {
        stub(condition: isHost("test.host") && pathEndsWith("v1/events")) { _ in
            HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil).responseTime(0.3)
        }

        let expectation = expectation(description: "Completion called")
        var requestService: MobileRequestService? = MobileRequestService(requestManager: .stub)
        requestService?.sendEvents([Event(eventTypeKey: "key", date: Date(), parameters: [])]) { _ in
            expectation.fulfill()
        }
        requestService = nil

        waitForExpectations(timeout: 3.0)
    }

    private func wait(seconds: TimeInterval) {
        let expectation = expectation(description: "Wait for \(seconds) seconds")
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: seconds + 1.0)
    }

}
