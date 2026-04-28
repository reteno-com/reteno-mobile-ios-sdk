//
//  RetenoConfiguration.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.04.2024.
//

import Foundation

public struct RetenoConfiguration {
    /// Flag that indicates if automatic screen view tracking enabled
    /// `false` by default
    public let isAutomaticScreenReportingEnabled: Bool
    
    /// Flag that indicates if automatic app life cycle  tracking enabled
    /// `true` by default
    public let isAutomaticAppLifecycleReportingEnabled: Bool
    
    /// Flag that indicates whether the SDK reports foreground app lifecycle events
    /// (`ApplicationOpened` and `ApplicationBackgrounded`).
    ///
    /// When `true`, the SDK emits an `ApplicationOpened` event each time the app is opened
    /// (either a cold launch or a return from the background) and an `ApplicationBackgrounded`
    /// event whenever the app moves to the background.
    ///
    /// When `false`, neither of these two events is sent. Install/Update lifecycle events are
    /// unaffected and continue to be controlled by `isAutomaticAppLifecycleReportingEnabled`.
    ///
    /// `false` by default.
    public let isApplicationForegroundLifecycleReportingEnabled: Bool
    
    /// Flag that indicates if automatic push subsription status tracking enabled
    /// `true` by default
    public let isAutomaticPushSubsriptionReportingEnabled: Bool
    
    /// Configuration that controls automatic session tracking and reporting.
    /// `RetenoSessionConfiguration.default` by default.
    public let sessionConfiguration: RetenoSessionConfiguration
    
    /// Flag that indicates pause in InAppMessage presenting
    /// `false` by default
    public let isPausedInAppMessages: Bool
    
    /// Flag that indicates behaviour after paused is disabled
    /// `.postponeInApps` by default
    public let inAppMessagesPauseBehaviour: PauseBehaviour
    
    ///  Flag that indicates if `DebugMode` is enabled
    /// `false` by default
    public let isDebugMode: Bool
    
    ///  Flag that indicates if SDK should use`CustomDeviceIdProvider`
    /// `false` by default
    public let useCustomDeviceId: Bool
    
    public let deviceTokenHandlingMode: DeviceTokenHandlingMode
    
    public init(
        isAutomaticScreenReportingEnabled: Bool = false,
        isAutomaticAppLifecycleReportingEnabled: Bool = true,
        isApplicationForegroundLifecycleReportingEnabled: Bool = false,
        isAutomaticPushSubsriptionReportingEnabled: Bool = true,
        sessionConfiguration: RetenoSessionConfiguration = .default,
        isPausedInAppMessages: Bool = false,
        inAppMessagesPauseBehaviour: PauseBehaviour = .postponeInApps,
        isDebugMode: Bool = false,
        useCustomDeviceId: Bool = false,
        deviceTokenHandlingMode: DeviceTokenHandlingMode = .automatic
    ) {
        self.isAutomaticScreenReportingEnabled = isAutomaticScreenReportingEnabled
        self.isAutomaticAppLifecycleReportingEnabled = isAutomaticAppLifecycleReportingEnabled
        self.isApplicationForegroundLifecycleReportingEnabled = isApplicationForegroundLifecycleReportingEnabled
        self.isAutomaticPushSubsriptionReportingEnabled = isAutomaticPushSubsriptionReportingEnabled
        self.sessionConfiguration = sessionConfiguration
        self.isPausedInAppMessages = isPausedInAppMessages
        self.inAppMessagesPauseBehaviour = inAppMessagesPauseBehaviour
        self.isDebugMode = isDebugMode
        self.useCustomDeviceId = useCustomDeviceId
        self.deviceTokenHandlingMode = deviceTokenHandlingMode
    }
}

extension RetenoConfiguration: Codable {}
