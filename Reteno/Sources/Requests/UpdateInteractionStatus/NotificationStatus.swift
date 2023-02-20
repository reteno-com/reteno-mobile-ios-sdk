//
//  NotificationStatus.swift
//  Reteno
//
//  Created by Anna Sahaidak on 15.10.2022.
//

import Foundation

struct NotificationStatus: Codable {
    
    let id: String
    let interactionId: String
    let status: InteractionStatus
    let date: Date
    
    init(interactionId: String, status: InteractionStatus, date: Date) {
        self.id = UUID().uuidString
        self.interactionId = interactionId
        self.status = status
        self.date = date
    }
    
}

// MARK: ExpirableData

extension NotificationStatus: ExpirableData {
    
    static var logTitle: String { "Removed interactions" }
    
}

// MARK: Groupable

extension NotificationStatus: Groupable {
    
    static var keyTitle: String { "interaction_status" }
    var key: String { status.rawValue }
    
}
