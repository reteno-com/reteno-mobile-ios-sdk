//
//  RetenoDelayedInitializationTest.swift
//  RetenoExampleTests
//
//  Created by Serhii Navka on 06.08.2024.
//  Copyright © 2024 Yalantis. All rights reserved.
//

import XCTest
@testable import RetenoExample
@testable import Reteno

final class RetenoDelayedInitializationTest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        Reteno.sdkStateHelper.set(isInitialized: false)
    }
    
    override func tearDown() {
        super.tearDown()
        
        Reteno.sdkStateHelper.set(isDelayedInitialization: false)
    }
    
    func test_setInitializedBoolValueOnStart() {
        Reteno.start(apiKey: "SDK_API_KEY")
        
        XCTAssert(Reteno.sdkStateHelper.isInitialized, "Should be true")
        XCTAssert(!Reteno.sdkStateHelper.IsDelayedInitialization, "IsDelayedInitialization should be false")
    }
    
    func test_doNotSetInitializedBoolValueOnDelayedStart() throws {
        Reteno.delayedStart()
        
        XCTAssert(!Reteno.sdkStateHelper.isInitialized, "isInitialized should be false")
        XCTAssert(Reteno.sdkStateHelper.IsDelayedInitialization, "IsDelayedInitialization should be true")
    }
    
    func test_setInitializedBoolValueOnDelayedStartAndContinue() {
        Reteno.delayedStart()
        Reteno.delayedSetup(apiKey: "SDK_API_KEY")
        
        XCTAssert(Reteno.sdkStateHelper.isInitialized, "isInitialized should be true")
        XCTAssert(Reteno.sdkStateHelper.IsDelayedInitialization, "IsDelayedInitialization should be true")
    }
}
