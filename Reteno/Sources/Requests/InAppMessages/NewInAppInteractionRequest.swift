//
//  NewInAppInteractionRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct NewInAppInteractionRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/interaction"
    let method: HTTPMethod = .post
    let encoding: any ParameterEncoding = JSONEncoding.default

    init(newInteraction: NewInteraction) {
        parameters = newInteraction.toJSON()
    }
    
}
