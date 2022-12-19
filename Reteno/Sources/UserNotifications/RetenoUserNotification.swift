//
//  RetenoUserNotification.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UserNotifications

struct RetenoUserNotification {
    
    struct ActionButton {
        
        let actionId: String
        let title: String
        let link: URL?
        let rawLink: URL?
        let iconPath: String?
        let customData: [String: Any]?
        
        init?(json: [String: Any]) {
            guard
                let actionId = json["action_id"] as? String,
                let title = json["label"] as? String
            else { return nil }
            
            self.actionId = actionId
            self.title = title
            link = (json["link"] as? String).flatMap { URL(string: $0) }
            rawLink = (json["link_raw"] as? String).flatMap { URL(string: $0) }
            iconPath = json["ios_icon_path"] as? String
            customData = json["custom_data"] as? [String: Any]
        }
        
    }
    
    let id: String
    let imageURLString: String?
    let link: URL?
    let rawLink: URL?
    let actionButtons: [ActionButton]?
    
    init?(userInfo: [AnyHashable: Any]) {
        guard let id = userInfo["es_interaction_id"] as? String else { return nil }
        
        self.id = id
        imageURLString = userInfo["es_notification_image"] as? String
        link = (userInfo["es_link"] as? String).flatMap { URL(string: $0) }
        rawLink = (userInfo["es_link_raw"] as? String).flatMap { URL(string: $0) }
        if let buttonsString = userInfo["es_buttons"] as? String,
           let buttonsData = buttonsString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: buttonsData, options: []),
           let jsons = jsonObject as? [[String: Any]] {
            actionButtons = jsons.compactMap { ActionButton(json: $0) }
        } else {
            actionButtons = nil
        }
    }
    
}
