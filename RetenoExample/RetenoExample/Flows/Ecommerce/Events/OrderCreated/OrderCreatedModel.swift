//
//  OrderCreatedModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

protocol OrderCreatedModelNavigationHandler {
    
    func createOrderItem(completion: @escaping (OrderItem) -> Void)
    func popViewController()
    
}

final class OrderCreatedModel {
    
    enum State {
        case create, update
    }
    
    var title: String {
        switch state {
        case .create:
            return NSLocalizedString("ecommerce_screen.order_created_button.title", comment: "")
            
        case .update:
            return NSLocalizedString("ecommerce_screen.order_updated_button.title", comment: "")
        }
    }
    
    private var items: [OrderItem] = []
    
    private let state: State
    private let navigationHandler: OrderCreatedModelNavigationHandler
    
    init(navigationHandler: OrderCreatedModelNavigationHandler, state: State) {
        self.navigationHandler = navigationHandler
        self.state = state
    }
    
    func sendEvent(
        externalOrderId: String,
        totalCost: Float,
        status: String,
        currency: String?,
        attributes: [String: String]?
    ) {
        let order = Ecommerce.Order(
            externalOrderId: externalOrderId,
            totalCost: totalCost,
            status: Ecommerce.Order.Status(rawValue: status) ?? .INITIALIZED,
            date: Date(),
            cartId: attributes?["cartId"],
            email: attributes?["email"],
            phone: attributes?["phone"],
            firstName: attributes?["firstName"],
            lastName: attributes?["lastName"],
            shipping: attributes?["shipping"].flatMap { Float($0) },
            discount: attributes?["discount"].flatMap { Float($0) },
            taxes: attributes?["taxes"].flatMap { Float($0) },
            restoreUrl: attributes?["restoreUrl"],
            statusDescription: attributes?["statusDescription"],
            storeId: attributes?["storeId"],
            source: attributes?["source"],
            deliveryMethod: attributes?["deliveryMethod"],
            paymentMethod: attributes?["paymentMethod"],
            deliveryAddress: attributes?["deliveryAddress"],
            items: items
        )
        let eventType: Ecommerce.EventType = {
            switch state {
            case .create:
                return .orderCreated(order: order, currencyCode: currency)
                
            case .update:
                return .orderUpdated(order: order, currencyCode: currency)
            }
        }()
        Reteno.ecommerce().logEvent(type: eventType)
    }
    
    func backToEcommerce() {
        navigationHandler.popViewController()
    }
    
    func createOrderItem() {
        navigationHandler.createOrderItem { [weak self] item in
            guard let self = self else { return }
            
            self.items.append(item)
            self.navigationHandler.popViewController()
        }
    }
}
