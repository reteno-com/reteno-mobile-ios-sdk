//
//  InAppMessageContentRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppMessageContentRequest: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/inapp/contents/request"
    let method: HTTPMethod = .post
    let encoding: any ParameterEncoding = JSONEncoding.default

    init(messageInstanceIds: [Int]) {
        let json = ["messageInstanceIds": messageInstanceIds]
        parameters = json
    }
    
}

