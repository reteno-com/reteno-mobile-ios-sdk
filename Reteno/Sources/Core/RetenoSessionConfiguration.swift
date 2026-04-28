//
//  RetenoSessionConfiguration.swift
//  Reteno
//
//  Created by Reteno on 16.04.2026.
//

import Foundation

public struct RetenoSessionConfiguration {
    /// Inactivity interval (in seconds) after which the current session is considered finished.
    /// Once this amount of time has passed since the last user activity, the next activity starts a new session.
    /// Default is `3 * 60 * 60` (3 hours).
    public let sessionDuration: TimeInterval
    
    /// Flag that indicates if automatic reporting of session start events is enabled.
    /// When `true`, the SDK reports a session start event at the beginning of each session.
    /// `true` by default.
    public let isSessionStartReportingEnabled: Bool
    
    /// Flag that indicates if automatic reporting of session end events is enabled.
    /// When `true`, the SDK reports a session end event when a session expires due to inactivity.
    /// Independent from `isSessionStartReportingEnabled`.
    /// `false` by default.
    public let isSessionEndReportingEnabled: Bool
    
    public init(
        sessionDuration: TimeInterval,
        isSessionStartReportingEnabled: Bool,
        isSessionEndReportingEnabled: Bool
    ) {
        self.sessionDuration = sessionDuration
        self.isSessionStartReportingEnabled = isSessionStartReportingEnabled
        self.isSessionEndReportingEnabled = isSessionEndReportingEnabled
    }
    
    /// Default session configuration.
    /// `sessionDuration` = `3 * 60 * 60` seconds, `isSessionStartReportingEnabled` = `true`, `isSessionEndReportingEnabled` = `false`.
    public static let `default` = RetenoSessionConfiguration(
        sessionDuration: 3 * 60 * 60,
        isSessionStartReportingEnabled: true,
        isSessionEndReportingEnabled: false
    )
    
    /// Configuration that fully disables session tracking and reporting.
    /// `sessionDuration` = `0`, `isSessionStartReportingEnabled` = `false`, `isSessionEndReportingEnabled` = `false`.
    public static let disabled = RetenoSessionConfiguration(
        sessionDuration: 0,
        isSessionStartReportingEnabled: false,
        isSessionEndReportingEnabled: false
    )
}

extension RetenoSessionConfiguration: Codable {}
