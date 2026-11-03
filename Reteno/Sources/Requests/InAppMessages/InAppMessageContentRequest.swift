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

    init(messages: [Message]) {
        headers = WorkflowContext.headers
        precondition(!messages.isEmpty && messages.count <= 100)
        parameters = ["messages": messages.map { ["iid": $0.iid!, "messageInstanceId": $0.messageInstanceId] as [String: Any] }]
    }
}

