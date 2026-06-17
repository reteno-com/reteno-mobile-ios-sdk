//
//  CustomEventModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class CustomEventModel {
    
    func logEvent(eventTypeKey: String, parameters: [Event.Parameter]) {
        Reteno.logEvent(
            eventTypeKey: eventTypeKey,
            date: Date(),
            parameters: parameters,
            forcePush: true
        )
    }
}
