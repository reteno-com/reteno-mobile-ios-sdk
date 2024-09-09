//
//  ApiRequestMock.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

@testable import Reteno

struct ApiRequestMock: APIRequest {
    
    var headers: [String: String]? = .init()
    var parameters: Parameters? = Parameters()
    
    let path: String
    let method: HTTPMethod = HTTPMethod.post
    let encoding: any ParameterEncoding = JSONEncoding.default
    
}
