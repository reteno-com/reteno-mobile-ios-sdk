//
//  ErrorEvent.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 20.10.2023.
//

import Foundation
import UIKit

public struct ErrorEvent: Codable {
    public enum LogLevel: String {
        case error
        case info
        case warning
    }

    let id: String
    let date: Date
    let logLevel: String
    let data: [String: String]?
    let errorMessage: String
    
    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        logLevel: LogLevel,
        data: [String: String]? = nil,
        errorMessage: String
    ) {
        self.id = id
        self.date = date
        self.logLevel = logLevel.rawValue
        self.data = data
        self.errorMessage = errorMessage
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        
        json["id"] = id
        json["platformName"] = "iOS"
        json["version"] = AppVersionHelper.appVersion()
        json["device"] = UIDevice.current.model
        json["sdkVersion"] = Reteno.version
        json["deviceId"] = DeviceIdHelper.deviceId() ?? ""
        json["bundleId"] = BundleIdHelper.getMainAppBundleId()
        json["logLevel"] = logLevel
        json["osVersion"] = UIDevice.current.systemVersion
        if let customData = data {
            json["data"] = customData
        }
        json["errorMessage"] = errorMessage
    
        return json
    }
}
