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
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
    static func buildMobileApiManager(apiKey: String = ApiKeyHelper.getApiKey()) -> RequestManager  {
        let headersDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
            request.headers?.add(name: "X-Reteno-Access-Key", value: apiKey)
            request.headers?.add(name: "X-Reteno-SDK-Version", value: Reteno.version)
        }
        let parametersDecorator = RequestDecorator { request in
            request.parameters?["deviceId"] = DeviceIdHelper.deviceId() ?? ""
            request.parameters?["externalUserId"] = ExternalUserIdHelper.getId()
        }
        
        return RequestManager(
            decorators: [headersDecorator, parametersDecorator],
            baseURLComponent: BaseURL.retenoMobile.rawValue
        )
    }
    
}
