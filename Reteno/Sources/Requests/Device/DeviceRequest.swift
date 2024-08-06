//
//  DeviceRequest.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import Alamofire
import UIKit

struct DeviceRequest: APIRequest {
    
    var headers: HTTPHeaders? = .init()
    var parameters: Parameters?
    
    let path: String
    let method = HTTPMethod.post
    let encoding: ParameterEncoding? = JSONEncoding.default
    
    init(
        category: DeviceCategory,
        osType: String = "IOS",
        osVersion: String = UIDevice.current.systemVersion,
        deviceModel: String = UIDevice.current.model,
        languageCode: String? = nil,
        advertisingId: String? = AdvertisingIdHelper.getAdvertisingId(),
        timeZone: String = TimeZone.current.identifier,
        pushToken: String,
        isSubscribedOnPush: Bool,
        appVersion: String? = AppVersionHelper.appVersion(),
        externalUserId: String? = nil,
        email: String?,
        phone: String?
    ) {
        path = "v1/device"
        
        var tempParameters: [String: Any] = [
            "category": category.rawValue,
            "osType": osType,
            "osVersion": osVersion,
            "deviceModel": deviceModel,
            "timeZone": timeZone,
            "pushToken": pushToken,
            "pushSubscribed": isSubscribedOnPush
        ]
        tempParameters["languageCode"] = languageCode
        tempParameters["advertisingId"] = advertisingId
        tempParameters["appVersion"] = appVersion
        tempParameters["externalUserId"] = externalUserId
        tempParameters["email"] = email
        tempParameters["phone"] = phone
                
        parameters = tempParameters
    }
    
}
