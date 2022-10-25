//
//  SendNotificationsStatusOperation.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation

final class SendNotificationsStatusOperation: DateOperation {
    
    private let sendingService: SendingServices
    private let storage: KeyValueStorage
    private let notificationStatus: NotificationStatus
    
    init(sendingService: SendingServices, storage: KeyValueStorage, notificationStatus: NotificationStatus) {
        self.sendingService = sendingService
        self.storage = storage
        self.notificationStatus = notificationStatus
        
        super.init(date: notificationStatus.date)
    }
    
    override func main() {
        super.main()
        
        sendingService.updateInteractionStatus(
            interactionId: notificationStatus.interactionId,
            token: RetenoNotificationsHelper.deviceToken() ?? "",
            status: notificationStatus.status,
            date: notificationStatus.date
        ) { [unowned self, notificationStatus] result in
            if case .success = result {
                self.storage.clearNotificationStatus(notificationStatus)
            }
            self.finish()
        }
    }
    
}
