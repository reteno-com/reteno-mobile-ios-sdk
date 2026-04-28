//
//  AnalyticsServiceTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 03.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import RetenoExample
@testable import Reteno

final class AnalyticsServiceTests: XCTestCase {

    private var sut: AnalyticsService!
    private var storage: KeyValueStorage!
    private var userDefaults: UserDefaults!
    private var notificationCenter: NotificationCenter!
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests")
        storage = KeyValueStorage(storage: userDefaults)
        notificationCenter = NotificationCenter.default
    }
    
    override func tearDown() {
        storage.clearEventsCache()
        userDefaults.removeSuite(named: "unit_tests")
        sut = nil
    }
    
    func test_AppControllerViewDidAppearMethod_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = AppInboxViewController(viewModel: AppInboxViewModel(model: AppInboxModel()))
        viewController.viewDidAppear(true)
                
        let events = storage.getEvents()
        let screenViewEvent = events.first(where: { $0.eventTypeKey == ScreenViewEvent })
        XCTAssertNotNil(screenViewEvent, "screenView event should NOT be nil")
        XCTAssertEqual(screenViewEvent!.eventTypeKey, ScreenViewEvent, "should have valid `eventTypeKey`")
        XCTAssertEqual(screenViewEvent!.parameters[0].name, ScreenClass, "should have screen class parameter name")
        XCTAssertEqual(
            screenViewEvent!.parameters[0].value,
            String(describing: type(of: viewController)),
            "should have screen class parameter value"
        )
    }
    
    func test_controllerViewDidLoadMethod_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = AppInboxViewController(viewModel: AppInboxViewModel(model: AppInboxModel()))
        viewController.viewDidLoad()
        
        let events = storage.getEvents()
        XCTAssertTrue(events.isEmpty, "shouldn't be tracked")
    }
        
    func test_appOpened_sendEvent() {
        setupService(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: true
        )
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationOpened" }
        XCTAssertTrue(events.isNotEmpty, "event should exist")
    }
    
    func test_appOpenedDisabledEvent_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true, isAutomaticAppLifecycleReportingEnabled: false)
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationOpened" }
        XCTAssertTrue(events.isEmpty, "event should NOT exist")
    }
    
    func test_appOpenedForegroundLifecycleReportingDisabled_doesNotSendEvent() {
        setupService(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: false
        )
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationOpened" }
        XCTAssertTrue(events.isEmpty, "event should NOT exist when foreground lifecycle reporting is disabled")
    }
    
    func test_appBackgrounded_sendEvent() {
        setupService(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: true
        )
        // Application can't be beckgrounded without become active
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationBackgrounded" }
        XCTAssertTrue(events.isNotEmpty, "event should exist")
    }
    
    func test_appBackgroundedDisabledEvent_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true, isAutomaticAppLifecycleReportingEnabled: false)
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationBackgrounded" }
        XCTAssertTrue(events.isEmpty, "event should exist")
    }
    
    func test_appBackgroundedForegroundLifecycleReportingDisabled_doesNotSendEvent() {
        setupService(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: false
        )
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationBackgrounded" }
        XCTAssertTrue(events.isEmpty, "event should NOT exist when foreground lifecycle reporting is disabled")
    }
    
    func test_appLifeCycle_sendEvent() {
        setupService(
            isAutomaticScreenReportingEnabled: true,
            isAutomaticAppLifecycleReportingEnabled: true,
            isApplicationForegroundLifecycleReportingEnabled: true
        )
        notificationCenter.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let events = storage.getEvents().filter { $0.eventTypeKey == "ApplicationBackgrounded" || $0.eventTypeKey == "ApplicationOpened" }
        XCTAssertTrue(events.isNotEmpty, "event should exist")
    }
    
    // MARK: - Helpers
    
    private func setupService(
        isAutomaticScreenReportingEnabled: Bool = false,
        isAutomaticAppLifecycleReportingEnabled: Bool = false,
        isApplicationForegroundLifecycleReportingEnabled: Bool = false
    ) {
        sut = AnalyticsService(
            isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled,
            isAutomaticAppLifecycleReportingEnabled: isAutomaticAppLifecycleReportingEnabled,
            isApplicationForegroundLifecycleReportingEnabled: isApplicationForegroundLifecycleReportingEnabled,
            storage: storage
        )
        Reteno.analyticsService = sut
    }

}
