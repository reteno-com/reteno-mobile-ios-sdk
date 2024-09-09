//
//  InAppBaseHTMLRequest.swift
//  Reteno
//
//  Created by Anna Sahaidak on 25.01.2023.
//

import Foundation

struct InAppBaseHTMLRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.head
    let encoding: any ParameterEncoding = URLEncoding.default

}
