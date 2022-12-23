//
//  CartUpdatedModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

struct ProductInCartPresentable {
    
    let productId: String
    let price: Float
    let quantity: Int
    let discount: Float?
    let name: String?
    let category: String?
    let attributes: [String: [String]]?
    
}

final class CartUpdatedModel {
    
    private let navigationHandler: EcommerceViewsNavigationHandler
    
    init(navigationHandler: EcommerceViewsNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func backToEcommerce() {
        navigationHandler.backToEcommerce()
    }
    
    func sendEvend(cartID: String, currencyCode: String?, isForcePushed: Bool, products: [ProductInCartPresentable]) {
        Reteno.ecommerce().logEvent(
            type: .cartUpdated(
                cartId: cartID,
                products: products.map {
                    Ecommerce.ProductInCart(productId: $0.productId, price: $0.price, quantity: $0.quantity, discount: $0.discount, name: $0.name, category: $0.category, attributes: $0.attributes)
                },
                currencyCode: currencyCode
            ),
            forcePush: isForcePushed
        )
    }
    
}
