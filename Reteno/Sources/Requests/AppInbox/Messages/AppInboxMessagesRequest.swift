//
//  AppInboxMessagesRequest.swift
//  
//
//  Created by Anna Sahaidak on 25.10.2022.
//

import Foundation

struct AppInboxMessagesRequest: APIRequest {

    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/appinbox/messages"
    let method = HTTPMethod.get
    let encoding: any ParameterEncoding = URLEncoding.default
    
    init(page: Int?, pageSize: Int?, status: AppInboxMessagesStatus?) {
        var params: [String: Any] = [:]
        if let status {
            params["status"] = status.rawValue
        }
        
        if let page = page, let pageSize = pageSize {
            params["page"] =  page
            params["pageSize"] = pageSize
        }
        parameters = params.isEmpty ? nil : params
    }

}
