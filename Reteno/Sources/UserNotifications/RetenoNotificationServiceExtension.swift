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
    
    private let imageCarouselCategoryIdentifier = "ImageCarousel"
    
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

        guard let notification = RetenoUserNotification(userInfo: request.content.userInfo) else {
            contentHandler(bestAttemptContent)
            return
        }
        
        Reteno.updateNotificationInteractionStatus(interactionId: notification.id, status: .delivered, date: Date())

        addActionButtons(from: notification, to: bestAttemptContent)
        
        if let imagesURLStrings = notification.imagesURLStrings, imagesURLStrings.isNotEmpty {
            buildAttachments(by: imagesURLStrings) { attachments in
                bestAttemptContent.attachments = attachments
                contentHandler(bestAttemptContent)
            }
        } else if let mediaURLString = notification.imageURLString {
            buildAttachments(by: [mediaURLString]) { attachments in
                bestAttemptContent.attachments = attachments
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
    
    // MARK: Helpers
    
    private func buildAttachments(by urlStrings: [String], completionHandler: @escaping ([UNNotificationAttachment]) -> Void) {
        var attachments: [UNNotificationAttachment] = []
        let dispatchGroup = DispatchGroup()
        urlStrings.forEach { urlString in
            dispatchGroup.enter()
            let fileType = URL(fileURLWithPath: urlString).pathExtension
            loadAttachment(by: urlString, fileType: fileType) { attachment in
                dispatchGroup.leave()
                
                guard let attachment = attachment else { return }

                attachments.append(attachment)
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            completionHandler(attachments)
        }
    }
    
    private func loadAttachment(by urlString: String, fileType: String, completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        guard let url = URL(string: urlString) else {
            completionHandler(nil)
            return
        }
        
        AF.download(url).response { response in
            if let error = response.error {
                SentryHelper.capture(error: error)
            }
            
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
                SentryHelper.capture(error: moveError)
                Logger.log("Failed to move file: \(moveError.localizedDescription)", eventType: .error)
                completionHandler(nil)
                return
            }
            
            // Create the notification attachment from the file
            var attachment: UNNotificationAttachment? = nil
            do {
                attachment = try UNNotificationAttachment(identifier: "image", url: localURL, options: nil)
                completionHandler(attachment)
            } catch let attachmentError {
                SentryHelper.capture(error: attachmentError)
                Logger.log("Failed to move file: \(attachmentError.localizedDescription)", eventType: .error)
                completionHandler(nil)
            }
        }
    }
    
    private func addActionButtons(from notification: RetenoUserNotification, to content: UNMutableNotificationContent) {
        guard let actionButtons = notification.actionButtons,
              actionButtons.isNotEmpty,
              content.categoryIdentifier.isEmpty || content.categoryIdentifier == imageCarouselCategoryIdentifier
        else {
            // Since notifications with images carousel always have the same categoryIdentifier,
            // we have to update setted previously category, because it might have registered action buttons.
            if content.categoryIdentifier == imageCarouselCategoryIdentifier {
                let category = UNNotificationCategory(identifier: imageCarouselCategoryIdentifier, actions: [], intentIdentifiers: [])
                updateNotificationCategories(with: category)
            }
            return
        }
        
        let actions: [UNNotificationAction] = actionButtons.map {
            if #available(iOS 15.0, *) {
                return UNNotificationAction(
                    identifier: $0.actionId,
                    title: $0.title,
                    options: .foreground,
                    icon: $0.iconPath.flatMap { UNNotificationActionIcon(templateImageName: $0) }
                )
            } else {
                return UNNotificationAction(identifier: $0.actionId, title: $0.title, options: .foreground)
            }
        }
        
        let categoryIdentifier = content.categoryIdentifier.isEmpty ? "__reteno__\(notification.id)" : content.categoryIdentifier
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: actions,
            intentIdentifiers: []
        )
        updateNotificationCategories(with: category)
        content.categoryIdentifier = categoryIdentifier
    }
    
    private func updateNotificationCategories(with category: UNNotificationCategory) {
        var existingCategories = getAllNotificationCategories()
        if !existingCategories.contains(where: { $0.identifier == category.identifier }) {
            existingCategories.append(category)
        } else if category.identifier == imageCarouselCategoryIdentifier {
            existingCategories.removeAll(where: { $0.identifier == category.identifier })
            existingCategories.append(category)
        }
        UNUserNotificationCenter.current().setNotificationCategories(Set(existingCategories))
        existingCategories = getAllNotificationCategories()
    }
    
    private func getAllNotificationCategories() -> [UNNotificationCategory] {
        var result: [UNNotificationCategory] = []
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationCategories { categories in
            result = Array(categories)
            semaphore.signal()
        }
        semaphore.wait()
        
        return result
    }
    
}
