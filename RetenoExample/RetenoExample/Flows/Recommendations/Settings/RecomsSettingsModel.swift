//
//  RecomsSettingsModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class RecomsSettingsModel {
    
    private(set) var settings: RecommendationsSettings
    
    private let navigationHandler: RecomsSettingsModelNavigationHandler
    
    init(settings: RecommendationsSettings, navigationHandler: RecomsSettingsModelNavigationHandler) {
        self.settings = settings
        self.navigationHandler = navigationHandler
    }
    
    func updateVariantId(_ id: String) {
        settings.variantId = id
    }
    
    func updateCategory(_ category: String?) {
        settings.category = category
    }
    
    func updateProductsIds(_ ids: [String]) {
        settings.productsIds = ids
    }
    
    func addFilter(name: String, values: [String]) {
        if settings.filters == nil {
            settings.filters = []
        }
        let recomFilter = RecomFilter(name: name, values: values)
        settings.filters?.append(recomFilter)
    }
    
    func clearFilters() {
        settings.filters = nil
    }
    
    func getRecoms() {
        navigationHandler.backToRecoms(settings: settings)
    }
    
}
