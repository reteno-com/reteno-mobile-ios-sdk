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
    
    init(
        recomVariantId: String,
        productIds: [String],
        categoryId: String?,
        filters: [RecomFilter]?,
        fields: [String]?
    ) {
        path = "v1/recoms/\(recomVariantId)/request"
        
        parameters = ["products": productIds]
        
        if let categoryId = categoryId,
           !categoryId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parameters?.updateValue(categoryId, forKey: "category")
        }
        if let filters = filters, !filters.isEmpty {
            let dicts = filters.map { $0.toJSON() }
            parameters?.updateValue(dicts, forKey: "filters")
        }
        if let fields = fields, !fields.isEmpty {
            parameters?.updateValue(fields, forKey: "fields")
        }
    }
    
}
