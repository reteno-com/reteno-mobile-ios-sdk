//
//  ProductViewedViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 14.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class ProductViewedViewModel {
    
    private let model: ProductViewedModel
    
    init(model: ProductViewedModel) {
        self.model = model
    }
    
    func sendEvent(
        productID: String,
        price: Float,
        isInStock: Bool,
        attributes: [String: [String]]?,
        currency: String?,
        isForcePushed: Bool
    ) {
        model.sendEvent(
            producId: productID,
            price: price,
            isInStock: isInStock,
            attributes: attributes,
            currency: currency,
            isForcePushed: isForcePushed
        )
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
}
