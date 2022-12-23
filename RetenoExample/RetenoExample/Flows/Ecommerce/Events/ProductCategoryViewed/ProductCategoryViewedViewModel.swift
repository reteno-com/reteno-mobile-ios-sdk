//
//  ProductCategoryViewedViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class ProductCategoryViewedViewModel {
    
    private let model: ProductCategoryViewedModel
    
    init(model: ProductCategoryViewedModel) {
        self.model = model
    }
    
    func sendEvent( categoryId: String, attributes: [String: [String]]?, isForcePushed: Bool) {
        model.sendEvent(categoryId: categoryId, attributes: attributes, isForcePushed: isForcePushed)
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
}
