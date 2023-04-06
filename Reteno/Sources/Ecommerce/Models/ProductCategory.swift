//
//  ProductCategory.swift
//  
//
//  Created by Anna Sahaidak on 30.11.2022.
//

import Foundation

extension Ecommerce {
    
    public struct ProductCategory {
        
        let productCategoryId: String
        let attributes: [String: [String]]?
        
        public init(productCategoryId: String, attributes: [String : [String]]? = nil) {
            self.productCategoryId = productCategoryId
            self.attributes = attributes
        }
        
        func convertToString() -> String? {
            var json: [String: Any] = ["productCategoryId": productCategoryId]
            attributes?.forEach { key, value in
                json[key] = value
            }
            
            return JSONConverterHelper.convertJSONToString(json)
        }
    }
    
}
