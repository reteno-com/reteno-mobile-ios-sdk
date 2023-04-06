//
//  Product.swift
//  
//
//  Created by Anna Sahaidak on 30.11.2022.
//

import Foundation

extension Ecommerce {
    
    public struct Product {
        
        let productId: String
        let price: Float
        let isInStock: Bool
        let attributes: [String: [String]]?
        
        public init(productId: String, price: Float, isInStock: Bool, attributes: [String: [String]]? = nil) {
            self.productId = productId
            self.price = price
            self.isInStock = isInStock
            self.attributes = attributes
        }
        
        func convertToString() -> String? {
            var json: [String: Any] = [
                "productId": productId,
                "price": price,
                "isInStock": isInStock ? 1 : 0
            ]
            attributes?.forEach { key, value in
                json[key] = value
            }
            
            return JSONConverterHelper.convertJSONToString(json)
        }
    }
    
}
