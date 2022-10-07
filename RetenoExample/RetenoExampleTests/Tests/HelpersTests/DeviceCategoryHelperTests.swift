//
//  DeviceCategoryHelperTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 04.10.2022.
//

import XCTest
import Foundation
@testable import Reteno

final class DeviceCategoryHelperTests: XCTestCase {
    
    func test_getDeviceCategory_withPhoneIdiom() {
        let type = DeviceCategoryHelper.deviceType(from: .phone)
        
        XCTAssertEqual(type, DeviceCategory.mobile, "result type should be equal to \(DeviceCategory.mobile)")
    }
    
    func test_getDeviceCategory_withPadIdiom() {
        let type = DeviceCategoryHelper.deviceType(from: .pad)
        
        XCTAssertEqual(type, DeviceCategory.tablet, "result type should be equal to \(DeviceCategory.tablet)")
    }
    
}
