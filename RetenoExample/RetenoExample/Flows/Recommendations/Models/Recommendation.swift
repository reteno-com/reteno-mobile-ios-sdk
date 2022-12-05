//
//  Recommendation.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 11.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

struct Recommendation: Decodable, RecommendableProduct {
    
    let productId: String
    let name: String
    let description: String
    let imageUrl: URL?
    let price: Float
    
    enum CodingKeys: String, CodingKey {
        case productId, name, description = "descr", imageUrl, price
    }
    
}
