//
//  RecommendableProduct.swift
//  
//
//  Created by Anna Sahaidak on 28.11.2022.
//

import Foundation

public protocol RecommendableProduct: JSONInitable {
    
    var productId: String { get }
    
}
