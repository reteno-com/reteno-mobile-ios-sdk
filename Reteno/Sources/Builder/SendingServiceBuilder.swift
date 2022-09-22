//
//  SendingServiceBuilder.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

public struct SendingServiceBuilder {
    
    public static func build() -> SendingServices {
        let requestManager = UnauthorizedAuthNetworkBuilder.build()
        
        return SendingServices(requestManager: requestManager)
    }
    
    public static func buildWithApiKey(_ key: String) -> SendingServices {
        let requestManager = NetworkBuilder.build(apiKey: key)
        
        return SendingServices(requestManager: requestManager)
    }
    
}
