//
//  SendNotificationsStatusOperation.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation

final class SendNotificationsStatusOperation: DateOperation, @unchecked Sendable {
    
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
        
        guard !isCancelled, storage.getNotificationStatuses().contains(where: { $0.id == notificationStatus.id }) else {
            finish()
            
            return
        }
        
        let token = RetenoNotificationsHelper.deviceToken() ?? ""
        if token.isEmpty {
            ErrorLogger.shared.captureWarningEvent(
                message: "Sending interaction status with empty token",
                tags: [
                    "reteno.interaction_id": notificationStatus.interactionId,
                    "reteno.interaction_status": notificationStatus.status.rawValue
                ]
            )
        }
        sendingService.updateInteractionStatus(
            status: notificationStatus,
            token: token
        ) { [notificationStatus] result in
            switch result {
            case .success:
                self.storage.clearNotificationStatus(notificationStatus)
                
            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
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

final class SendWorkflowInteractionOperation: DateOperation, @unchecked Sendable {
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let queued: QueuedInAppInteraction

    init(requestService: MobileRequestService, storage: KeyValueStorage, queued: QueuedInAppInteraction) {
        self.requestService = requestService
        self.storage = storage
        self.queued = queued
        super.init(date: queued.interaction.time)
    }

    override func main() {
        super.main()
        guard !isCancelled, queued.context == WorkflowContext.current,
              storage.pendingWorkflowInteractions(context: queued.context, now: Date()).contains(where: { $0.id == queued.id }) else {
            finish()
            return
        }
        requestService.sendWorkflowInteraction(queued) { result, response in
            switch result {
            case .success:
                self.storage.completeWorkflowInteraction(id: self.queued.id, retryAt: nil)
            case .failure:
                let status = response?.statusCode ?? -1
                let retryable = status < 0 || status == 408 || status == 429 || status >= 500
                var delay = min(3600.0, pow(2.0, Double(self.queued.attempts)) * 30)
                if let text = response?.headers.getHeaderValue(for: "Retry-After") {
                    if let seconds = Double(text) {
                        delay = max(delay, seconds)
                    } else {
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
                        if let date = formatter.date(from: text) { delay = max(delay, date.timeIntervalSinceNow) }
                    }
                }
                Logger.log(retryable && self.queued.attempts < 7 ? "Workflow interaction retry scheduled" : "Workflow interaction finished without acknowledgment", eventType: .warning)
                self.storage.completeWorkflowInteraction(id: self.queued.id,
                    retryAt: retryable ? Date().addingTimeInterval(delay) : nil)
            }
            self.finish()
        }
    }
}
