//
//  NotificationStatus.swift
//  Reteno
//
//  Created by Anna Sahaidak on 15.10.2022.
//

import Foundation

struct NotificationStatus: Codable {
    
    struct Action: Codable {
        let type: String
        let targetComponentId: String?
        let url: String?
        
        init(type: String, targetComponentId: String?, url: String? = nil) {
            self.type = type
            self.targetComponentId = targetComponentId
            self.url = url
        }
    }
    
    let id: String
    let interactionId: String
    let status: InteractionStatus
    let date: Date
    let action: Action?
    
    init(interactionId: String, status: InteractionStatus, date: Date, action: Action? = nil) {
        self.id = UUID().uuidString
        self.interactionId = interactionId
        self.status = status
        self.date = date
        self.action = action
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
