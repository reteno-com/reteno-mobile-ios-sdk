//
//  RegisterLinkClickRequest.swift
//  
//
//  Created by Anna Sahaidak on 04.11.2022.
//

import Alamofire

struct RegisterLinkClickRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.head
    let encoding: ParameterEncoding? = URLEncoding.default
    
    init(link: String) {
        path = link
    }
    
}
