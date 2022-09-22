//
//  UnauthorizedAuthNetworkBuilder.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 13.09.2022.
//

import Foundation

struct UnauthorizedAuthNetworkBuilder {
    
    static func build() -> RequestManager {
        let contentTypeDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
}
