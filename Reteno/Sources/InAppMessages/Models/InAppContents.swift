//
//  InAppContents.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppContents: Decodable {
    
    let contents: [InAppContent]
    
}

struct InAppContent: InApp {
    let id: String
    
    let messageInstanceId: Int
    let layoutType: LayoutType
    let model: String
    
    enum CodingKeys: String, CodingKey {
        case messageInstanceId, layoutType, model
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messageInstanceId = try container.decode(Int.self, forKey: .messageInstanceId)
        self.id = String(messageInstanceId)
        self.layoutType = LayoutType(rawValue: try container.decode(String.self, forKey: .layoutType)) ?? .full
        
        let modelPayload = try container.decode([String: Any].self, forKey: .model)
        let modelData = try JSONSerialization.data(withJSONObject: modelPayload)
        self.model = String(data: modelData, encoding: .utf8) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageInstanceId, forKey: .messageInstanceId)
        try container.encode(self.layoutType, forKey: .layoutType)
        
        if let data = self.model.data(using: .utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            try container.encode(json, forKey: .model)
        }
    }
    
}
