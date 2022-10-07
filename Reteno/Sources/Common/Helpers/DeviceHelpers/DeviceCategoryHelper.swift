//
//  DeviceCategoryHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import Foundation

struct DeviceCategoryHelper {
    
    private init() {}
    
    static func deviceType(from idiom: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom) -> DeviceCategory {
        switch idiom {
        case .phone:
            return .mobile
            
        case .pad:
            return .tablet
            
        default:
            preconditionFailure("Reteno Error: unsupported device category")
        }
    }
    
}
