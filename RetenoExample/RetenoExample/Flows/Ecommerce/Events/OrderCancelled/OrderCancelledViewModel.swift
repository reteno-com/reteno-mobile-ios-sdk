//
//  OrderDeliveredViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class OrderCancelledViewModel {
    
    private let model: OrderCancelledModel
    
    init(model: OrderCancelledModel) {
        self.model = model
    }
    
    func sendEvent(_ orderId: String, isForcePushed: Bool) {
        model.sendEvent(orderId: orderId, isForcePushed: isForcePushed)
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
}
