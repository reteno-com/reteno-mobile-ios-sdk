//
//  ProductCategoryViewedModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class ProductCategoryViewedModel {
    
    private let navigationHandler: EcommerceViewsNavigationHandler
    
    init(navigationHandler: EcommerceViewsNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func sendEvent(categoryId: String, attributes: [String: [String]]?, isForcePushed: Bool) {
        Reteno.ecommerce().logEvent(
            type: .productCategoryViewed(
                category: Ecommerce.ProductCategory(
                    productCategoryId: categoryId,
                    attributes: attributes
                )
            ),
            forcePush: isForcePushed)
    }
    
    func backToEcommerce() {
        navigationHandler.backToEcommerce()
    }
    
}
