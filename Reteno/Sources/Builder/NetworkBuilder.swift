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
            request.headers?.add(name: "Content-Type", value: "application/json")
            request.headers?.add(name: "Authorization", value: "Basic \(token)")
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.add(name: "X-Reteno-Debug", value: "true")
            }
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
    static func buildMobileApiManager(
        apiKey: String = ApiKeyHelper.getApiKey(),
        isExternalIdRequired: Bool = true
    ) -> RequestManager {
        let headersDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
            request.headers?.add(name: "X-Reteno-Access-Key", value: apiKey)
            request.headers?.add(name: "X-Reteno-SDK-Version", value: DevicePlatformHelper.getDevicePlatform())
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.add(name: "X-Reteno-Debug", value: "true")
            }
        }
        let parametersDecorator = RequestDecorator { request in
            request.parameters?["deviceId"] = DeviceIdHelper.deviceId() ?? ""
            if isExternalIdRequired {
                request.parameters?["externalUserId"] = ExternalUserIdHelper.getId()
            }
        }
        
        return RequestManager(
            decorators: [headersDecorator, parametersDecorator],
            baseURLComponent: BaseURL.retenoMobile.rawValue
        )
    }
    
    static func buildApiManagerForDeviceProviding() -> RequestManager {
        buildMobileApiManager(isExternalIdRequired: false)
    }
    
    static func buildApiManagerWithDeviceIdInHeaders(apiKey: String = ApiKeyHelper.getApiKey()) -> RequestManager {
        let headersDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
            request.headers?.add(name: "X-Reteno-Access-Key", value: apiKey)
            request.headers?.add(name: "X-Reteno-SDK-Version", value: DevicePlatformHelper.getDevicePlatform())
            if let deviceId = DeviceIdHelper.deviceId() {
                request.headers?.add(name: "X-Reteno-Device-ID", value: deviceId)
            }
            if DebugModeHelper.isDebugModeOn() {
                request.headers?.add(name: "X-Reteno-Debug", value: "true")
            }
        }
        
        return RequestManager(
            decorators: [headersDecorator],
            baseURLComponent: BaseURL.retenoMobile.rawValue
        )
    }
    
    static func buildApiManagerWithEmptyBaseURL() -> RequestManager {
        RequestManager(decorators: [], baseURLComponent: "")
    }
    
}
