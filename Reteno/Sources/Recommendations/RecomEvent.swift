//
//  RecomEvent.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Foundation

public struct RecomEvent: Codable {
    
    let date: Date
    let productId: String
    
    public init(date: Date, productId: String) {
        self.date = date
        self.productId = productId
    }
    
    func toJSON() -> [String: Any] {
        [
            "occurred": DateFormatter.baseBEDateFormatter.string(from: date),
            "productId": productId
        ]
    }

}
