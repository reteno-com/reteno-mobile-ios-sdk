//
//  MobileRequestServiceBuilder.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Foundation

struct MobileRequestServiceBuilder {
    
    private init() {}
    
    static func build() -> MobileRequestService {
        MobileRequestService()
    }
    
    static func buildForDeviceRequest() -> MobileRequestService {
        MobileRequestService(requestManager: NetworkBuilder.buildApiManagerForDeviceProviding())
    }
    
    static func buildWithDeviceIdInHeaders() -> MobileRequestService {
        MobileRequestService(requestManager: NetworkBuilder.buildApiManagerWithDeviceIdInHeaders())
    }
    
}
