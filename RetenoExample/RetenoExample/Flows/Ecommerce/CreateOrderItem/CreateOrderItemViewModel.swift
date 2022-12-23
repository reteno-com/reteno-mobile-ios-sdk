//
//  CreateOrderItemViewModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 21.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class CreateOrderItemViewModel {
    
    private let model: CreateOrderItemModel
    
    init(model: CreateOrderItemModel) {
        self.model = model
    }
    
    func createOrderItem(_ item: OrderItem) {
        model.createOrderItem(item)
    }

}
