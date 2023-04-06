//
//  InAppScriptEventRequest.swift
//  
//
//  Created by Anna Sahaidak on 26.01.2023.
//

import Foundation
import Alamofire

struct InAppScriptEventRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "https://site-script.reteno.com/site-script/v1/event"
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(messageId: String, data: [String: Any]) {
        parameters = [
            "scriptVersion": "latest",
            "orgId": 0,
            "siteId": 0,
            "tenantId": messageId,
            "guid": "null",
            "url": "https://statics.reteno.com/in-app/base.latest.html",
            "message": "IN_APP_IOS",
            "log_level": "ERROR",
            "data": JSONConverterHelper.convertJSONToString(data) ?? ""
        ]
    }

}
