//
//  InAppMessageRequest.swift
//  
//
//  Created by Anna Sahaidak on 18.01.2023.
//

import Foundation

struct InAppMessageRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.get
    let encoding: any ParameterEncoding = URLEncoding.default
    
    init(id: String) {
        path = "v1/inapp/interactions/\(id)/message"
    }

}
