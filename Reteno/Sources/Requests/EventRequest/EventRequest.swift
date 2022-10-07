//
//  EventRequest.swift
//  Reteno
//
//  Created by Anna Sahaidak on 29.09.2022.
//

import Alamofire

struct EventRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(events: [Event]) {
        path = "v1/events"
        parameters = ["events": events.map { $0.toJSON() }]
    }
    
}
