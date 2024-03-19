//
//  NewInteraction.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

enum NewInteractionStatus: String {
    case opened = "OPENED", failed = "FAILED"
}

struct NewInteraction {
    let id: String
    let time: Date
    let messageInstanceId: Int
    let status: NewInteractionStatus
    let statusDescription: String?
    
    init(
        id: String = UUID().uuidString,
        time: Date,
        messageInstanceId: Int,
        status: NewInteractionStatus,
        statusDescription: String?
    ) {
        self.id = id
        self.time = time
        self.messageInstanceId = messageInstanceId
        self.status = status
        self.statusDescription = statusDescription
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        
        json["iid"] = id
        json["time"] = DateFormatter.baseBEDateFormatter.string(from: time)
        json["messageInstanceId"] = messageInstanceId
        json["status"] = status.rawValue
        
        if let statusDescription = statusDescription {
            json["statusDescription"] = statusDescription
        }
 
        return json
    }
    
}
