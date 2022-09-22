//
//  NetworkBuilder.swift
//  Reteno
//
//  Created by Anna Sahaidak on 16.09.2022.
//

import Foundation

struct NetworkBuilder {
    
    static func build(apiKey: String) -> RequestManager {
        let token = "username:\(apiKey)".data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        let contentTypeDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
            request.headers?.add(name: "Authorization", value: "Basic \(token)")
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
}
