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
    
    /// Flag that indicates if automatic push subsription status tracking enabled
    /// `true` by default
    public let isAutomaticPushSubsriptionReportingEnabled: Bool
    
    /// Flag that indicates if automatic session tracking events enabled
    /// `true` by default
    public let isAutomaticSessionReportingEnabled: Bool
    
    /// Flag that indicates pause in InAppMessage presenting
    /// `false` by default
    public let isPausedInAppMessages: Bool
    
    /// Flag that indicates behaviour after paused is disabled
    /// `.postponeInApps` by default
    public let inAppMessagesPauseBehaviour: PauseBehaviour
    
    ///  Flag that indicates if `DebugMode` is enabled
    /// `false` by default
    public let isDebugMode: Bool
    
    public init(
        isAutomaticScreenReportingEnabled: Bool = false,
        isAutomaticAppLifecycleReportingEnabled: Bool = true,
        isAutomaticPushSubsriptionReportingEnabled: Bool = true,
        isAutomaticSessionReportingEnabled: Bool = true,
        isPausedInAppMessages: Bool = false,
        inAppMessagesPauseBehaviour: PauseBehaviour = .postponeInApps,
        isDebugMode: Bool = false
    ) {
        self.isAutomaticScreenReportingEnabled = isAutomaticScreenReportingEnabled
        self.isAutomaticAppLifecycleReportingEnabled = isAutomaticAppLifecycleReportingEnabled
        self.isAutomaticPushSubsriptionReportingEnabled = isAutomaticPushSubsriptionReportingEnabled
        self.isAutomaticSessionReportingEnabled = isAutomaticSessionReportingEnabled
        self.isPausedInAppMessages = isPausedInAppMessages
        self.inAppMessagesPauseBehaviour = inAppMessagesPauseBehaviour
        self.isDebugMode = isDebugMode
    }
}

extension RetenoConfiguration: Codable {}
