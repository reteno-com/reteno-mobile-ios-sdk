//
//  NewInAppInteractionRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation
import Alamofire

struct NewInAppInteractionRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/interaction"
    let method: HTTPMethod = .post
    let encoding: ParameterEncoding? = JSONEncoding.default

    init(newInteraction: NewInteraction) {
        parameters = newInteraction.toJSON()
    }
    
}
