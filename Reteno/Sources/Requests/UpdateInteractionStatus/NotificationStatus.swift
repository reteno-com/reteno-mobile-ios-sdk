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
    
    static var logTitle: String { "Notification Statuses" }
    
}
