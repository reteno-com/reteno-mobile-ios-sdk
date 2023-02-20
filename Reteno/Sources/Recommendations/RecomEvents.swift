//
//  RecomEvents.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Foundation

struct RecomEvents: Codable {
    
    let id: String
    let date: Date
    let recomVariantId: String
    let impressions: [RecomEvent]
    let clicks: [RecomEvent]
    
    init(date: Date = Date(), recomVariantId: String, impressions: [RecomEvent], clicks: [RecomEvent]) {
        self.id = UUID().uuidString
        self.date = date
        self.recomVariantId = recomVariantId
        self.impressions = impressions
        self.clicks = clicks
    }

    func toJSON() -> [String: Any] {
        var json: [String: Any] = ["recomVariantId": recomVariantId]
        if impressions.isNotEmpty {
            json["impressions"] = impressions.map { $0.toJSON() }
        }
        if clicks.isNotEmpty {
            json["clicks"] = clicks.map { $0.toJSON() }
        }
        return json
    }
    
}

// MARK - ExpirableData

extension RecomEvents: ExpirableData {
    
    static var logTitle: String { "Removed recommendations" }
    
}
