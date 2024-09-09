//
//  RecomEventsRequest.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

struct RecomEventsRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: any ParameterEncoding = JSONEncoding.default
    
    init(events: [RecomEvents]) {
        path = "v1/recoms/events"
        
        parameters = ["events": events.map { $0.toJSON() }]
    }

}
