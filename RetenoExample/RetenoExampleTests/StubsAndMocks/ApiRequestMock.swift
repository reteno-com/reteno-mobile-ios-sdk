//
//  ApiRequestMock.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Alamofire
@testable import Reteno

struct ApiRequestMock: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters? = Parameters()
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
}
