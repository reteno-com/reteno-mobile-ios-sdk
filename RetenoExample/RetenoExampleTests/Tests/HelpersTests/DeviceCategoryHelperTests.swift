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
    
    func test_getDeviceCategory_withPhoneIdiom() throws {
        let type = try DeviceCategoryHelper.deviceType(from: .phone)
        
        XCTAssertEqual(type, DeviceCategory.mobile, "result type should be equal to \(DeviceCategory.mobile)")
    }
    
    func test_getDeviceCategory_withPadIdiom() throws {
        let type = try DeviceCategoryHelper.deviceType(from: .pad)
        
        XCTAssertEqual(type, DeviceCategory.tablet, "result type should be equal to \(DeviceCategory.tablet)")
    }
    
}
