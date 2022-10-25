//
//  MainModel.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 21.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

protocol MainModelNavigationHandler {
    
    func openMenu()
    func createProfile()
    
}

final class MainModel {
    
    private let navigationHandler: MainModelNavigationHandler
    
    init(navigationHandler: MainModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func openMenu() {
        navigationHandler.openMenu()
    }
    
    func logCustomEvent() {
        Reteno.logEvent(
            eventTypeKey: "test_event_type",
            parameters: [Event.Parameter(name: "Parameter name", value: "some parameter value")],
            forcePush: true
        )
	}
	
    func openProfile() {
        navigationHandler.createProfile()
    }
    
}
