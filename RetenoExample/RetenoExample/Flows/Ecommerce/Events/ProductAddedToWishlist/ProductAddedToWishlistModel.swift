//
//  ProductAddedToWishlistModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class ProductAddedToWishlistModel {
    
    private let navigationHandler: EcommerceModelNavigationHandler
    
    init(navigationHandler: EcommerceModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func sendEvent(
        producId: String,
        price: Float,
        isInStock: Bool,
        attributes: [String: [String]]?,
        currency: String?,
        isForcePushed: Bool
    ) {
        Reteno.ecommerce().logEvent(
            type: .productAddedToWishlist(
                product: Ecommerce.Product(
                    productId: producId,
                    price: price,
                    isInStock: isInStock,
                    attributes: attributes
                ),
                currencyCode: currency
            ),
            forcePush: isForcePushed
        )
    }
    
    func backToEcommerce() {
        navigationHandler.backToEcommerce()
    }
    
}
