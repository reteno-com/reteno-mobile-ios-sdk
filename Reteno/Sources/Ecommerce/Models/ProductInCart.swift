//
//  ProductInCart.swift
//  
//
//  Created by Anna Sahaidak on 30.11.2022.
//

import Foundation

extension Ecommerce {
    
    public struct ProductInCart {
        
        let productId: String
        let price: Float
        let quantity: Int
        
        let discount: Float?
        let name: String?
        let category: String?
        
        let attributes: [String: [String]]?
        
        public init(
            productId: String,
            price: Float,
            quantity: Int,
            discount: Float? = nil,
            name: String? = nil,
            category: String? = nil,
            attributes: [String : [String]]? = nil
        ) {
            self.productId = productId
            self.price = price
            self.quantity = quantity
            self.discount = discount
            self.name = name
            self.category = category
            self.attributes = attributes
        }
        
        func toJSON() -> [String: Any] {
            var json: [String: Any] = [
                "productId": productId,
                "price": price,
                "quantity": quantity
            ]
            if let discount = discount {
                json["discount"] = discount
            }
            if let name = name {
                json["name"] = name
            }
            if let category = category {
                json["category"] = category
            }
            attributes?.forEach { key, value in
                json[key] = value
            }
            
            return json
        }
    }
    
}
