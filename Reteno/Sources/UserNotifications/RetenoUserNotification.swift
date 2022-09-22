//
//  RetenoUserNotification.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UserNotifications

struct RetenoUserNotification {
    
    let id: String
    let imageURLString: String?
    let link: URL?
    
    init?(userInfo: [AnyHashable: Any]) {
        guard let id = userInfo["es_interaction_id"] as? String else { return nil }
        
        self.id = id
        imageURLString = userInfo["es_notification_image"] as? String
        link = (userInfo["es_link"] as? String).flatMap { URL(string: $0) }
    }
    
}
