//
//  BundleIdHelperTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 26.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class BundleIdHelperTests: XCTestCase {

    func test_getMainAppBundleId() throws {
        let bundle = try XCTUnwrap(Bundle(identifier: "com.reteno.example-app"), "should have value")
        let result = BundleIdHelper.getMainAppBundleId(bundle: bundle)
        
        XCTAssertEqual(result, "com.reteno.example-app", "should return valid id")
    }

}
