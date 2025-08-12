//
//  CustomInAppURLViewModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 02.07.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import Foundation

final class CustomInAppURLViewModel {
    
    private let model: CustomInAppURLModel
    
    init(model: CustomInAppURLModel) {
        self.model = model
    }
    
    func updateIsCustomURL(isCustomURL: Bool) {
        model.updateIsCustomToggle(isCustomURL)
    }
    
    func getCustomURL() -> String? {
        model.getCustomURL()
    }
    
    func isCustomURL() -> Bool {
        model.isCustomInAppURL()
    }
    
    func save(customURL: String) {
        model.save(url: customURL)
    }
}
