//
//  CreateContactRequest.swift
//  Reteno
//
//  Created by Anna Sahaidak on 16.09.2022.
//

import Foundation
import Alamofire

struct CreateContactRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(token: String) {
        path = "v1/contact"
        
        let channel: [String: Any] = ["type": "mobilepush", "value": token, "device": ["os": "ios"]]
        parameters = ["channels": [channel]]
    }
    
}
