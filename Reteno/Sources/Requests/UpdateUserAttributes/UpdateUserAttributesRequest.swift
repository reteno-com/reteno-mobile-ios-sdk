//
//  UpdateUserAttributesRequest.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Alamofire

struct UpdateUserAttributesRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(
        externalUserId: String,
        deviceId: String = DeviceIdHelper.deviceId() ?? "",
        userAttributes: UserAttributes? = nil,
        subscriptionKeys: [String] = [],
        groupNamesInclude: [String] = [],
        groupNamesExclude: [String] = []
    ) {
        path = "v1/user"
        
        var tempParameters: [String: Any] = [
            "deviceId": deviceId,
            "externalUserId": externalUserId
        ]
        
        tempParameters["userAttributes"] = userAttributes?.toJSON()
        tempParameters["subscriptionKeys"] = subscriptionKeys.isEmpty ? nil : subscriptionKeys
        tempParameters["groupNamesInclude"] = groupNamesInclude.isEmpty ? nil : groupNamesInclude
        tempParameters["groupNamesExclude"] = groupNamesExclude.isEmpty ? nil : groupNamesExclude
        
        parameters = tempParameters
    }
    
}
