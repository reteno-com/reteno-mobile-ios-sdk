//
//  OrderDeliveredModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class OrderCancelledModel {
    
    private let navigationHandler: EcommerceModelNavigationHandler
    
    init(navigationHandler: EcommerceModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func sendEvent(orderId: String, isForcePushed: Bool) {
        Reteno.ecommerce().logEvent(type: .orderCancelled(externalOrderId: orderId), forcePush: isForcePushed)
    }
    
    func backToEcommerce() {
        navigationHandler.backToEcommerce()
    }
    
}
