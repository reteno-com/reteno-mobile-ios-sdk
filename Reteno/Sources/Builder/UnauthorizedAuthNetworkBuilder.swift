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
            request.headers?.updateValue("application/json", forKey: "Content-Type")
        }
        
        return RequestManager(decorators: [contentTypeDecorator])
    }
    
}
