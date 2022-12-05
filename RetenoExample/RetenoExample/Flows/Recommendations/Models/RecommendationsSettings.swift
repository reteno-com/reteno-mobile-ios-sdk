//
//  RecommendationsSettings.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

struct RecommendationsSettings {
    
    var variantId: String
    var category: String
    var productsIds: [String]
    var filters: [RecomFilter]
    
    static func defaultSettings() -> RecommendationsSettings {
        RecommendationsSettings(
            variantId: "r1107v1482",
            category: "Default Category/Training/Video Download",
            productsIds: ["240-LV09", "24-WG080"],
            filters: []
        )
    }
    
}
