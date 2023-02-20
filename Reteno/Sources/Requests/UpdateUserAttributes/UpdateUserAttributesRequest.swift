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
    
    let path: String = "v1/user"
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(
        externalUserId: String?,
        deviceId: String = DeviceIdHelper.deviceId() ?? "",
        userAttributes: UserAttributes? = nil,
        subscriptionKeys: [String] = [],
        groupNamesInclude: [String] = [],
        groupNamesExclude: [String] = []
    ) {        
        var tempParameters: [String: Any] = ["deviceId": deviceId]
        if let externalUserId = externalUserId {
            tempParameters["externalUserId"] = externalUserId
        }
        tempParameters["userAttributes"] = userAttributes?.toJSON()
        tempParameters["subscriptionKeys"] = subscriptionKeys.isEmpty ? nil : subscriptionKeys
        tempParameters["groupNamesInclude"] = groupNamesInclude.isEmpty ? nil : groupNamesInclude
        tempParameters["groupNamesExclude"] = groupNamesExclude.isEmpty ? nil : groupNamesExclude
        
        parameters = tempParameters
    }
    
}
