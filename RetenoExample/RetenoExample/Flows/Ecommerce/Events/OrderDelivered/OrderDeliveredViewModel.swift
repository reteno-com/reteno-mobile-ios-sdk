//
//  OrderDeliveredViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class OrderDeliveredViewModel {
    
    private let model: OrderDeliveredModel
    
    init(model: OrderDeliveredModel) {
        self.model = model
    }
    
    func sendEvent(_ orderId: String, isForcePushed: Bool) {
        model.sendEvent(orderId: orderId, isForcePushed: isForcePushed)
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
}
