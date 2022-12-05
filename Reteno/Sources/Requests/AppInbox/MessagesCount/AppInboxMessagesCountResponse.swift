//
//  AppInboxMessagesCountResponse.swift
//  
//
//  Created by Serhii Prykhodko on 26.10.2022.
//

import Foundation

struct AppInboxMessagesCountResponse {
    
    let unreadCount: Int
    
}

// MARK: Decodable

extension AppInboxMessagesCountResponse: Decodable {}
