//
//  CustomEventViewModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class CustomEventViewModel {
    
    private let model: CustomEventModel
    
    init(model: CustomEventModel) {
        self.model = model
    }
    
    func logEvent(eventTypeKey: String, parameters: [Event.Parameter]) {
        model.logEvent(eventTypeKey: eventTypeKey, parameters: parameters)
    }
}
