//
//  AppInboxMessagesResponse.swift
//  
//
//  Created by Anna Sahaidak on 25.10.2022.
//

import Foundation

struct AppInboxMessagesResponse: Codable {
    
    let messages: [AppInboxMessage]
    let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case messages = "list", totalPages
    }

}
