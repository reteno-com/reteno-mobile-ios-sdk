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
    
    private var userDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        
        Reteno.isInitialized = false
        userDefaults = UserDefaults(suiteName: "unit_tests")
        Reteno.storage = KeyValueStorage(storage: userDefaults)
    }
    
    override func tearDown() {
        super.tearDown()
        
        Reteno.storage.set(isDelayedInitialization: false)
        userDefaults.removeSuite(named: "unit_tests")
    }
    
    func test_setInitializedBoolValueOnStart() {
        Reteno.start(apiKey: "SDK_API_KEY")
        
        XCTAssert(Reteno.isInitialized, "Should be true")
        XCTAssert(!Reteno.storage.getIsDelayedInitialization(), "getIsDelayedInitialization should be false")
    }
    
    func test_doNotSetInitializedBoolValueOnDelayedStart() throws {
        Reteno.delayedStart()
        
        XCTAssert(!Reteno.isInitialized, "isInitialized should be false")
        XCTAssert(Reteno.storage.getIsDelayedInitialization(), "getIsDelayedInitialization should be true")
    }
    
    func test_setInitializedBoolValueOnDelayedStartAndContinue() {
        Reteno.delayedStart()
        Reteno.delayedSetup(apiKey: "SDK_API_KEY")
        
        XCTAssert(Reteno.isInitialized, "isInitialized should be true")
        XCTAssert(Reteno.storage.getIsDelayedInitialization(), "getIsDelayedInitialization should be true")
    }
}
