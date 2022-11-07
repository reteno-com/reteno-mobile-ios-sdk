//
//  MainViewModel.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 21.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class MainViewModel {
    
    var updateCountHandler: ((Int) -> Void)? {
        didSet {
            model.updateCountHandler = updateCountHandler
        }
    }
    
    private let model: MainModel
    
    init(model: MainModel) {
        self.model = model
    }
    
    func openMenu() {
        model.openMenu()
    }
    
    func logCustomEvent() {
        model.logCustomEvent()
	}
	
    func openProfile() {
        model.openProfile()
    }
    
    func openAppInbox() {
        model.openAppInbox()
    }
    
}
