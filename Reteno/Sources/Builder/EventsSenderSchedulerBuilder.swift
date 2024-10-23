//
//  EventsSenderSchedulerBuilder.swift
//  
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

struct EventsSenderSchedulerBuilder {
    
    private init() {}
    
    static func build() -> EventsSenderScheduler {
        EventsSenderScheduler(mobileRequestService: MobileRequestServiceBuilder.build())
    }

}
