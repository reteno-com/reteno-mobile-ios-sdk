//
//  SendingServiceBuilder.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

struct SendingServiceBuilder {
    
    private init() {}
    
    static func build() -> SendingServices {
        let requestManager = NetworkBuilder.build()
        
        return SendingServices(requestManager: requestManager)
    }
    
    static func buildServiceWithEmptyURL() -> SendingServices {
        let requestManager = NetworkBuilder.buildApiManagerWithEmptyBaseURL()
        
        return SendingServices(requestManager: requestManager)
    }
    
}
