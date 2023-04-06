//
//  UpdateInteractionStatusRequest.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 13.09.2022.
//

import Foundation
import Alamofire

struct UpdateInteractionStatusRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.put
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(status: NotificationStatus, token: String? = nil) {
        path = "v1/interactions/\(status.interactionId)/status"
        
        var parameters = Parameters()
        if let token = token {
            parameters["token"] = token
        }
        parameters["status"] = status.status.rawValue
        parameters["time"] = DateFormatter.baseBEDateFormatter.string(from: status.date)
        if let action = status.action {
            var actionParameters = ["type": action.type]
            action.targetComponentId.flatMap { actionParameters["targetComponentId"] = $0 }
            action.url.flatMap { actionParameters["url"] = $0 }
            parameters["action"] = actionParameters
        }
        
        self.parameters = parameters
    }
}
