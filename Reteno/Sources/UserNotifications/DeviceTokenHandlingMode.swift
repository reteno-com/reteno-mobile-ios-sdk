//
//  DeviceTokenHandlingMode.swift
//  Reteno
//
//  Created by George Farafonov on 29.12.2025.
//

import Foundation

/// Defines how the SDK obtains the device push token.
public enum DeviceTokenHandlingMode: String, Codable {
    /// The SDK automatically retrieves the device push token using method swizzling.
    ///
    /// Use this mode when you use APNs directly and do not need to implement
    /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` yourself.
    case automatic

    /// The host application is responsible for providing the device push token manually.
    ///
    /// Use this mode when you use FCM or need your own implementation of
    /// `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.
    case manual
}
