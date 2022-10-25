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
    
    override func setUp() {
        userDefaults = UserDefaults(suiteName: "unit_tests")
        storage = KeyValueStorage(storage: userDefaults)
    }
    
    override func tearDown() {
        storage.clearEventsCache()
        userDefaults.removeSuite(named: "unit_tests")
        sut = nil
    }
    
    func test_controllerViewDidAppearMethod_sendEvent() throws {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = MenuViewController(viewModel: MenuViewModel(model: MenuModel()))
        viewController.viewDidAppear(true)
                
        let events = storage.getEvents()
        XCTAssertEqual(events[0].eventTypeKey, ScreenViewEvent, "should have valid `eventTypeKey`")
        XCTAssertEqual(events[0].parameters[0].name, ScreenClass, "should have screen class parameter name")
        XCTAssertEqual(
            events[0].parameters[0].value,
            String(describing: type(of: viewController)),
            "should have screen class parameter value"
        )
    }
    
    func test_controllerViewDidLoadMethod_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = MenuViewController(viewModel: MenuViewModel(model: MenuModel()))
        viewController.viewDidLoad()
        
        let events = storage.getEvents()
        XCTAssertTrue(events.isEmpty, "shouldn't be tracked")
    }
        
    // MARK: - Helpers
    
    private func setupService(isAutomaticScreenReportingEnabled isEnabled: Bool) {
        sut = AnalyticsService(isAutomaticScreenReportingEnabled: isEnabled, storage: storage)
        Reteno.analyticsService = sut
    }

}
