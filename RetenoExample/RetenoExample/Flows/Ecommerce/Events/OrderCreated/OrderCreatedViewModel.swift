//
//  OrderCreatedViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class OrderCreatedViewModel {
    
    var title: String { model.title }
    
    private let model: OrderCreatedModel

    init(model: OrderCreatedModel) {
        self.model = model
    }
    
    func sendEvent(
        externalOrderId: String,
        totalCost: Float,
        status: String,
        currency: String?,
        attributes: [String: String]?
    ) {
        model.sendEvent(
            externalOrderId: externalOrderId,
            totalCost: totalCost,
            status: status,
            currency: currency,
            attributes: attributes
        )
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
    func createOrderItem() {
        model.createOrderItem()
    }
}
