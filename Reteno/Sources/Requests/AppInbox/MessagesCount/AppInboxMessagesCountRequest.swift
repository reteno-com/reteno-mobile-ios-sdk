//
//  AppInboxMessagesCountRequest.swift
//  
//
//  Created by Serhii Prykhodko on 26.10.2022.
//

import Foundation

struct AppInboxMessagesCountRequest: APIRequest {
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/appinbox/messages/count"
    let method = HTTPMethod.get
    let encoding: any ParameterEncoding = URLEncoding.default

}
