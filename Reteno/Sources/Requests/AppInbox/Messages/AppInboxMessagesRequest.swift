//
//  AppInboxMessagesRequest.swift
//  
//
//  Created by Anna Sahaidak on 25.10.2022.
//

import Foundation
import Alamofire

struct AppInboxMessagesRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/appinbox/messages"
    let method = HTTPMethod.get
    let encoding: ParameterEncoding? = URLEncoding.default
    
    init(page: Int?, pageSize: Int?) {
        guard let page = page, let pageSize = pageSize else { return }
        
        parameters = ["page": page, "pageSize": pageSize]
    }

}
