//
//  AnalyticsServiceBuilder.swift
//  
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

struct AnalyticsServiceBuilder {
    
    private init() {}
    
    static func build(
        isAutomaticScreenReportingEnabled: Bool,
        isAutomaticAppLifecycleReportingEnabled: Bool
    ) -> AnalyticsService {
        AnalyticsService(
            isAutomaticScreenReportingEnabled: isAutomaticScreenReportingEnabled,
            isAutomaticAppLifecycleReportingEnabled: isAutomaticAppLifecycleReportingEnabled
        )
    }

}
