//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Anna Sahaidak on 15.09.2022.
//

import UserNotifications
import Reteno

class NotificationService: RetenoNotificationServiceExtension {
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        Reteno.logEvent(eventTypeKey: "push_delivered", parameters: [Event.Parameter(name: "isPushDelivered", value: "true")])
        
        super.didReceive(request, withContentHandler: contentHandler)
    }
}
