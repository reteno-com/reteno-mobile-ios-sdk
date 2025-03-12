//
//  InAppMessage.swift
//  
//
//  Created by Anna Sahaidak on 26.01.2023.
//

import Foundation

struct InAppMessage: InApp {
    let id: String
    let layoutType: LayoutType
    let layoutParams: LayoutParams?
    let model: String
    let personalisation: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "iid", layoutType, layoutParams, model, personalisation
    }
    
    init(id: String, layoutType: LayoutType = .full, model: String, personalisation: String?, layoutParams: LayoutParams? = nil) {
        self.id = id
        self.layoutType = layoutType
        self.model = model
        self.personalisation = personalisation
        self.layoutParams = layoutParams
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.layoutType = LayoutType(rawValue: try container.decode(String.self, forKey: .layoutType)) ?? .full
        
        let modelPayload = try container.decode([String: Any].self, forKey: .model)
        let modelData = try JSONSerialization.data(withJSONObject: modelPayload)
        self.model = String(data: modelData, encoding: .utf8) ?? ""
        
        if let personalisationPayload = try? container.decode([String: Any].self, forKey: .personalisation),
           let personalisationData = try? JSONSerialization.data(withJSONObject: personalisationPayload) {
            self.personalisation = String(data: personalisationData, encoding: .utf8)
        } else {
            self.personalisation = nil
        }
        
        self.layoutParams = try? container.decodeIfPresent(LayoutParams.self, forKey: .layoutParams)
    }

}

enum LayoutType: String, Codable {
    case full = "FULL"
    case slideUp = "SLIDE_UP"
    case bottomBar = "BOTTOM_BAR"
    case popup = "POP_UP"
}

struct LayoutParams: Codable {
    let position: LayoutPosition
}

enum LayoutPosition: String, Codable {
    case top = "TOP"
    case bottom = "BOTTOM"
}
