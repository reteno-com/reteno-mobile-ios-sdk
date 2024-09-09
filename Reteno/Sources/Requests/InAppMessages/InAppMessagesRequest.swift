//
//  InAppMessagesRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppMessagesRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/inapp/messages"
    let method = HTTPMethod.get
    let encoding: any ParameterEncoding = URLEncoding.default

    init(eTag: String?) {
        headers?.updateValue(eTag ?? "", forKey: "If-None-Match")
    }
    
}
