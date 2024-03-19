//
//  InAppMessageContentRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation
import Alamofire

struct InAppMessageContentRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/inapp/contents/request"
    let method: HTTPMethod = .post
    let encoding: ParameterEncoding? = JSONEncoding.default

    init(messageInstanceIds: [Int]) {
        let json = ["messageInstanceIds": messageInstanceIds]
        parameters = json
    }
    
}

