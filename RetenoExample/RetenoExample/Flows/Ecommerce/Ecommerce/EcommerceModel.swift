//
//  EcommerceModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 13.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

protocol EcommerceModelNavigationHandler {
    
    func backToEcommerce()
    
}

final class EcommerceModel {
    
    private let navigationHandler: EcommerceFlowNavigationHandler
    
    init(navigationHandler: EcommerceFlowNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func openProductViewed() {
        navigationHandler.openProductViewed()
    }
    
    func openProductCategoryViewed() {
        navigationHandler.openProductCategoryViewed()
    }
    
    func openProductAddedToWishlist() {
        navigationHandler.openProductAddedToWishlist()
    }
    
    func openCartUpdated() {
        navigationHandler.openCartUpdated()
    }
    
    func openOrderCreated() {
        navigationHandler.openOrderCreated()
    }
    
    func openOrderUpdated() {
        navigationHandler.openOrderUpdated()
    }
    
    func openOrderDelivered() {
        navigationHandler.openOrderDelivered()
    }
    
    func openOrderCancelled() {
        navigationHandler.openOrderCancelled()
    }
    
    func openSearchRequest() {
        navigationHandler.openSearchRequest()
    }
    
}
