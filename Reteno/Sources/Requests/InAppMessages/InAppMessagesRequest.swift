//
//  InAppMessagesRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation
import Alamofire

struct InAppMessagesRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/inapp/messages"
    let method = HTTPMethod.get
    let encoding: ParameterEncoding? = URLEncoding.default

    init(eTag: String?) {
        headers?.add(.init(name: "If-None-Match", value: eTag ?? ""))
    }
    
}
