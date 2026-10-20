//
//  MobileRequestServiceBuilder.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 29.09.2022.
//

import Foundation

struct MobileRequestServiceBuilder {
    
    private init() {}
    
    /// - Parameter identity: identity the requests are sent with; `nil` uses the identity current when each request is built
    static func build(identity: RequestIdentity? = nil) -> MobileRequestService {
        let provider = RequestIdentity.provider(for: identity)
        return MobileRequestService(
            requestManager: NetworkBuilder.buildMobileApiManager(identity: provider),
            identity: provider
        )
    }
    
    static func buildForDeviceRequest(identity: RequestIdentity? = nil) -> MobileRequestService {
        let provider = RequestIdentity.provider(for: identity)
        return MobileRequestService(
            requestManager: NetworkBuilder.buildApiManagerForDeviceProviding(identity: provider),
            identity: provider
        )
    }
    
    static func buildWithDeviceIdInHeaders(identity: RequestIdentity? = nil) -> MobileRequestService {
        let provider = RequestIdentity.provider(for: identity)
        return MobileRequestService(
            requestManager: NetworkBuilder.buildApiManagerWithDeviceIdInHeaders(identity: provider),
            identity: provider
        )
    }
    
}
