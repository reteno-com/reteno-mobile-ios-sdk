//
//  InAppBaseHTMLRequest.swift
//  Reteno
//
//  Created by Anna Sahaidak on 25.01.2023.
//

import Foundation
import Alamofire

struct InAppBaseHTMLRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.head
    let encoding: ParameterEncoding? = URLEncoding.default

}
