//
//  DeviceCategoryHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import Foundation
import UIKit

struct DeviceCategoryHelper {
    
    private init() {}
    
    static func deviceType(from idiom: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) throws -> DeviceCategory {
        switch idiom {
        case .phone:
            return .mobile
            
        case .pad:
            return .tablet
            
        default:
            let error = DeviceCategoryError()
            ErrorLogger.shared.capture(error: error)
            
            throw error
        }
    }
    
}

// MARK: DeviceCategoryError

struct DeviceCategoryError: Error {}

extension DeviceCategoryError: LocalizedError {
    
    var errorDescription: String? {
        "Unsupported interface idiom: \(UIDevice.current.userInterfaceIdiom.rawValue)"
    }
    
}
