//
//  ErrorEventRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 20.10.2023.
//

import Alamofire

struct ErrorEventRequest: APIRequest {
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(events: [ErrorEvent]) {
        path = "https://mobile-api.reteno.com/logs/v1/events"
        parameters = ["events": events.map { $0.toJSON() }]
    }
}
