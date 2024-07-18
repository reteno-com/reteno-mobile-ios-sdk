//
//  InboxMessage.swift
//  
//
//  Created by Anna Sahaidak on 25.10.2022.
//

import Foundation

public struct AppInboxMessage: Codable {
    
    public var createdDate: Date? { DateFormatter.baseBEDateFormatter.date(from: createdDateRawValue) }
    
    public let id: String
    public let title: String
    public let content: String?
    public let imageURL: URL?
    public let linkURL: URL?
    public let isNew: Bool
    public let category: String?
    public let customData: [String: Any]?
    public let expiryDate: Date?
    private let createdDateRawValue: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdDateRawValue = "createDate"
        case title
        case content
        case imageURL = "image"
        case linkURL = "link"
        case isNew = "newMessage"
        case category
        case customData
        case expiryDate
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try? container.decode(String.self, forKey: .content)
        self.imageURL = try? container.decode(URL.self, forKey: .imageURL)
        self.linkURL = try? container.decode(URL.self, forKey: .linkURL)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.category = try? container.decode(String.self, forKey: .category)
        self.customData = try? container.decode([String: Any].self, forKey: .customData)
        self.expiryDate = try? container.decode(Date.self, forKey: .expiryDate)
        self.createdDateRawValue = try container.decode(String.self, forKey: .createdDateRawValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(linkURL, forKey: .linkURL)
        try container.encode(isNew, forKey: .isNew)
        try container.encode(category, forKey: .category)
        try container.encode(customData, forKey: .customData)
        try container.encode(expiryDate, forKey: .expiryDate)
        try container.encode(createdDateRawValue, forKey: .createdDateRawValue)
    }
}
