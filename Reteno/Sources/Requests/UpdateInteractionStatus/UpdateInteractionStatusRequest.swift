//
//  UpdateInteractionStatusRequest.swift
//  Alamofire
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
    
    init(interactionId: String, token: String? = nil, status: InteractionStatus, time: Date? = nil) {
        path = "v1/interactions/\(interactionId)/status"
        
        var parameters = Parameters()
        if let token = token {
            parameters["token"] = token
        }
        parameters["status"] = status.rawValue
        if let time = time {
            parameters["time"] = DateFormatter.baseBEDateFormatter.string(from: time)
        }
        
        self.parameters = parameters
    }
}
