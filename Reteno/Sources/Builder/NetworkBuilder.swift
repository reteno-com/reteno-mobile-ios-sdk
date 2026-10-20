//
//  NetworkBuilder.swift
//  Reteno
//
//  Created by Anna Sahaidak on 16.09.2022.
//

import Foundation

struct NetworkBuilder {
    
    static func build(apiKey: String = ApiKeyHelper.getApiKey()) -> RequestManager {
        let token = "username:\(apiKey)".data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        let contentTypeDecorator = RequestDecorator { request in
            request.headers?.updateValue("application/json", forKey: "Content-Type")
            request.headers?.updateValue("Basic \(token)", forKey: "Authorization")
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.updateValue("true", forKey: "X-Reteno-Debug")
            }
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
    static func buildMobileApiManager(
        apiKey: @escaping @autoclosure () -> String = ApiKeyHelper.getApiKey(),
        isExternalIdRequired: Bool = true,
        identity: @escaping () -> RequestIdentity = { .current }
    ) -> RequestManager {
        let headersDecorator = RequestDecorator { request in
            request.headers?.updateValue("application/json", forKey: "Content-Type")
            request.headers?.updateValue(apiKey(), forKey: "X-Reteno-Access-Key")
            request.headers?.updateValue(DevicePlatformHelper.getDevicePlatform(), forKey: "X-Reteno-SDK-Version")
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.updateValue("true", forKey: "X-Reteno-Debug")
            }
        }
        let parametersDecorator = RequestDecorator { request in
            let identity = identity()
            request.parameters?["deviceId"] = identity.deviceId
            if isExternalIdRequired {
                request.parameters?["externalUserId"] = identity.externalUserId
            }
        }
        
        return RequestManager(
            baseURLComponent: BaseURL.retenoMobile.rawValue,
            decorators: [headersDecorator, parametersDecorator]
        )
    }
    
    static func buildApiManagerForDeviceProviding(identity: @escaping () -> RequestIdentity = { .current }) -> RequestManager {
        buildMobileApiManager(isExternalIdRequired: false, identity: identity)
    }
    
    static func buildApiManagerWithDeviceIdInHeaders(
        apiKey: @escaping @autoclosure () -> String = ApiKeyHelper.getApiKey(),
        identity: @escaping () -> RequestIdentity = { .current }
    ) -> RequestManager {
        let headersDecorator = RequestDecorator { request in
            request.headers?.updateValue("application/json", forKey: "Content-Type")
            request.headers?.updateValue(apiKey(), forKey: "X-Reteno-Access-Key")
            request.headers?.updateValue(DevicePlatformHelper.getDevicePlatform(), forKey: "X-Reteno-SDK-Version")
            let deviceId = identity().deviceId
            if !deviceId.isEmpty {
                request.headers?.updateValue(deviceId, forKey: "X-Reteno-Device-ID")
            }
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.updateValue("true", forKey: "X-Reteno-Debug")
            }
        }
        
        return RequestManager(
            baseURLComponent: BaseURL.retenoMobile.rawValue,
            decorators: [headersDecorator]
        )
    }
    
    static func buildApiManagerWithEmptyBaseURL() -> RequestManager {
        RequestManager(baseURLComponent: "", decorators: [])
    }
    
}
