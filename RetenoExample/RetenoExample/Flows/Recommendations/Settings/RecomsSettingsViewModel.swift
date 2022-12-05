//
//  RecomsSettingsViewModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class RecomsSettingsViewModel {
    
    var settings: RecommendationsSettings {
        model.settings
    }
    
    private let model: RecomsSettingsModel
    
    init(model: RecomsSettingsModel) {
        self.model = model
    }
    
    func updateVariantId(_ id: String) {
        model.updateVariantId(id)
    }
    
    func updateCategory(_ category: String) {
        model.updateCategory(category)
    }
    
    func updateProductsIds(_ ids: [String]) {
        model.updateProductsIds(ids)
    }
    
    func addFilter(name: String, values: [String]) {
        model.addFilter(name: name, values: values)
    }
    
    func clearFilters() {
        model.clearFilters()
    }
    
    func getRecoms() {
        model.getRecoms()
    }
    
}
