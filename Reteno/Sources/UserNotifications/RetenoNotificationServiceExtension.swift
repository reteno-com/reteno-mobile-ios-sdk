//
//  RetenoNotificationServiceExtension.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UserNotifications
import Alamofire

open class RetenoNotificationServiceExtension: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        guard RetenoNotificationsHelper.isRetenoPushNotification(request.content.userInfo) else {
            contentHandler(request.content)
            return
        }
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }

        // Store a reference to the mutable content and the contentHandler on the class so we
        // can use them in serviceExtensionTimeWillExpire if needed
        self.contentHandler = contentHandler
        self.bestAttemptContent = bestAttemptContent

        let notification = RetenoUserNotification(userInfo: request.content.userInfo)
        
        let service = SendingServiceBuilder.build()
        service.updateInteractionStatus(
            interactionId: notification?.id ?? "",
            token: RetenoNotificationsHelper.deviceToken() ?? "",
            status: .delivered
        )
        
        if let mediaURLString = notification?.imageURLString {
            buildAttachments(by: mediaURLString) { attachments in
                attachments.flatMap { bestAttemptContent.attachments = $0 }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }
    
    open override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: - Helpers
    
    private func buildAttachments(by urlString: String, completionHandler: @escaping ([UNNotificationAttachment]?) -> Void) {
        let fileType = URL(fileURLWithPath: urlString).pathExtension
        loadAttachment(by: urlString, fileType: fileType) { attachment in
            guard let attachment = attachment else {
                completionHandler(nil)
                return
            }

            completionHandler([attachment])
        }
    }
    
    private func loadAttachment(by urlString: String, fileType: String, completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }
        
        AF.download(url).response { response in
            guard let fileURL = response.fileURL else {
                completionHandler(nil)
                return
            }
            
            // Move the downloaded file to temp folder
            let fileManager = FileManager.default
            let localURL = URL(fileURLWithPath: fileURL.path + "." + fileType)
            do {
                try fileManager.moveItem(at: fileURL, to: localURL)
            } catch let moveError {
                print("Failed to move file: ", moveError.localizedDescription)
                completionHandler(nil)
                return
            }
            
            // Create the notification attachment from the file
            var attachment: UNNotificationAttachment? = nil
            do {
                attachment = try UNNotificationAttachment(identifier: "image", url: localURL, options: nil)
                completionHandler(attachment)
            } catch let attachmentError {
                print("Unable to add attachment: ", attachmentError.localizedDescription)
                completionHandler(nil)
            }
        }
    }
    
}
