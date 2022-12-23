//
//  CartUpdatedViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class CartUpdatedViewModel {
    
    private let model: CartUpdatedModel

    init(model: CartUpdatedModel) {
        self.model = model
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
    func sendEvent(cartID: String, currencyCode: String?, isForcePushed: Bool, products: [ProductInCartPresentable]) {
        model.sendEvend(cartID: cartID, currencyCode: currencyCode, isForcePushed: isForcePushed, products: products)
    }
}

