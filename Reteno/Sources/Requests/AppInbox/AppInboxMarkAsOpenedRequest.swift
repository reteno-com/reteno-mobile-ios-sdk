//
//  AppInboxMarkAsOpenedRequest.swift
//  
//
//  Created by Anna Sahaidak on 27.10.2022.
//

import Foundation
import Alamofire

struct AppInboxMarkAsOpenedRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/appinbox/messages/status"
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(ids: [String]?) {
        parameters = ["status": "OPENED"]
        if let ids = ids, ids.isNotEmpty {
            parameters?["ids"] = ids
        }
    }
    
}
