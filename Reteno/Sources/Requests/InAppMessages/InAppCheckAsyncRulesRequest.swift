//
//  InAppCheckAsyncRulesRequest.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 31.01.2024.
//

import Foundation

import Foundation
import Alamofire

struct InAppCheckAsyncRulesRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String = "v1/inapp/async-rules/check"
    let method: HTTPMethod = .post
    let encoding: ParameterEncoding? = JSONEncoding.default

    init(segmentsIds: [Int]) {
        var json: [String: Any] = [:]
        
        let segments:[[String:Any]] = segmentsIds.map {
            let segment:[String: Any] = ["type": "IS_IN_SEGMENT", "params": ["segmentId": $0]]
            return segment
        }
        
        json["checks"] = segments
        parameters = json
    }
    
}
