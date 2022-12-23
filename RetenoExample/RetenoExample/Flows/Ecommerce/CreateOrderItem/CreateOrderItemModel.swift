//
//  CreateOrderItemModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 21.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

typealias OrderItem = Ecommerce.Order.Item

final class CreateOrderItemModel {
    
    private let completion: (OrderItem) -> Void
    
    init(completion: @escaping (OrderItem) -> Void) {
        self.completion = completion
    }
    
    func createOrderItem(_ item: OrderItem) {
        completion(item)
    }

}
