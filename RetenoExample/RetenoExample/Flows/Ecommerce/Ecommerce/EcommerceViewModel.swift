//
//  EcommerceViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 13.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class EcommerceViewModel {
    
    private let model: EcommerceModel
    
    init(model: EcommerceModel) {
        self.model = model
    }
    
    func openProductViewed() {
        model.openProductViewed()
    }
    
    func openProductCategoryViewed() {
        model.openProductCategoryViewed()
    }
    
    func openProductAddedToWishlist() {
        model.openProductAddedToWishlist()
    }
    
    func openCartUpdated() {
        model.openCartUpdated()
    }
    
    func openOrderCreated() {
        model.openOrderCreated()
    }
    
    func openOrderUpdated() {
        model.openOrderUpdated()
    }
    
    func openOrderDelivered() {
        model.openOrderDelivered()
    }
    
    func openOrderCancelled() {
        model.openOrderCancelled()
    }
    
    func openSearchRequest() {
        model.openSearchRequest()
    }
    
}

