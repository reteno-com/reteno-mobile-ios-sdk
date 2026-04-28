//
//  SessionConfigViewModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 16.04.2026.
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

final class SessionConfigViewModel {
    
    private let model: SessionConfigModel
    
    init(model: SessionConfigModel) {
        self.model = model
    }
    
    var sessionDuration: TimeInterval { model.sessionDuration }
    var isSessionStartReportingEnabled: Bool { model.isSessionStartReportingEnabled }
    var isSessionEndReportingEnabled: Bool { model.isSessionEndReportingEnabled }
    var isApplicationForegroundLifecycleReportingEnabled: Bool {
        model.isApplicationForegroundLifecycleReportingEnabled
    }
    
    func save(
        sessionDuration: TimeInterval,
        isSessionStartReportingEnabled: Bool,
        isSessionEndReportingEnabled: Bool,
        isApplicationForegroundLifecycleReportingEnabled: Bool
    ) {
        model.save(
            sessionDuration: sessionDuration,
            isSessionStartReportingEnabled: isSessionStartReportingEnabled,
            isSessionEndReportingEnabled: isSessionEndReportingEnabled,
            isApplicationForegroundLifecycleReportingEnabled: isApplicationForegroundLifecycleReportingEnabled
        )
    }
}
