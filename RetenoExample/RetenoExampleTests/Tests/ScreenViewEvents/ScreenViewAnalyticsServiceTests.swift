//
//  ScreenViewAnalyticsServiceTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 03.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import RetenoExample
@testable import Reteno

final class ScreenViewAnalyticsServiceTests: XCTestCase {

    private var analyticsService: ScreenViewAnalyticsService!
    private var sut: EventsSenderMock!
    
    override func setUp() {
        sut = EventsSenderMock()
    }
    
    override func tearDown() {
        analyticsService = nil
        sut = nil
    }
    
    func test_controllerViewDidAppearMethod_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = MenuViewController(viewModel: MenuViewModel(model: MenuModel()))
        viewController.viewDidAppear(true)
                
        XCTAssertEqual(sut.eventTypeKey, ScreenViewEvent, "should have valid `eventTypeKey`")
        XCTAssertEqual(sut.params[0].name, ScreenClass, "should have screen class parameter name")
        XCTAssertEqual(sut.params[0].value, String(describing: type(of: viewController)), "should have screen class parameter value")
    }
    
    func test_controllerViewDidLoadMethod_sendEvent() {
        setupService(isAutomaticScreenReportingEnabled: true)
        let viewController = MenuViewController(viewModel: MenuViewModel(model: MenuModel()))
        viewController.viewDidLoad()
        
        XCTAssertTrue(sut.eventTypeKey.isEmpty, "shouldn't be tracked")
    }
        
    // MARK: - Helpers
    
    private func setupService(isAutomaticScreenReportingEnabled isEnabled: Bool) {
        analyticsService = ScreenViewAnalyticsService(
            isAutomaticScreenReportingEnabled: isEnabled,
            service: sut
        )
        Reteno.screenViewAnalyticsService = analyticsService
    }

}
