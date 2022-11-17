//
//  SendNotificationsStatusOperation.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation
import Alamofire

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
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        sendingService.updateInteractionStatus(
            interactionId: notificationStatus.interactionId,
            token: RetenoNotificationsHelper.deviceToken() ?? "",
            status: notificationStatus.status,
            date: notificationStatus.date
        ) { [weak self, notificationStatus] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.storage.clearNotificationStatus(notificationStatus)
                
            case .failure(let error):
                if let responseCode = (error as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearNotificationStatus(notificationStatus)
                        
                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }
    
}
