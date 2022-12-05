//
//  RecomsRequest.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Alamofire

struct RecomsRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(recomVariantId: String, productIds: [String], categoryId: String, filters: [RecomFilter]?, fields: [String]?) {
        path = "v1/recoms/\(recomVariantId)/request"
        
        parameters = ["products": productIds, "category": categoryId]
        if let filters = filters {
            parameters?["filters"] = filters.map { $0.toJSON() }
        }
        if let fields = fields {
            parameters?["fields"] = fields
        }
    }

}
