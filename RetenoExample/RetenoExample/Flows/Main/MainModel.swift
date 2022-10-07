//
//  MainModel.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 21.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

protocol MainModelNavigationHandler {
    
    func openMenu()
    
}

final class MainModel {
    
    private let navigationHandler: MainModelNavigationHandler
    
    init(navigationHandler: MainModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func openMenu() {
        navigationHandler.openMenu()
    }
    
}
