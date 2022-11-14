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
    private let createdDateRawValue: String
    
    enum CodingKeys: String, CodingKey {
        case id, createdDateRawValue = "createDate", title, content, imageURL = "image", linkURL = "link", isNew = "newMessage"
    }
    
}
