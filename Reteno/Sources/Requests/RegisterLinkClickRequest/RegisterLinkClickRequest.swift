//
//  RegisterLinkClickRequest.swift
//  
//
//  Created by Anna Sahaidak on 04.11.2022.
//


struct RegisterLinkClickRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.head
    let encoding: any ParameterEncoding = URLEncoding.default
    
    init(link: String) {
        path = link
    }
    
}
