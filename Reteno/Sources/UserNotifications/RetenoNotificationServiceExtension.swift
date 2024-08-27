//
//  RetenoNotificationServiceExtension.swift
//  Reteno
//
//  Created by Anna Sahaidak on 12.09.2022.
//

import UserNotifications

open class RetenoNotificationServiceExtension: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private let imageCarouselCategoryIdentifier = "ImageCarousel"
    private let session = URLSession(configuration: .default)
    
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
            loadAttachment(by: urlString) { attachment in
                if let attachment = attachment {
                    attachments.append(attachment)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.global()) {
            completionHandler(attachments)
        }
    }
    
    private func loadAttachment(by urlString: String, completionHandler: @escaping (UNNotificationAttachment?) -> Void) {
        guard let url = URL(string: urlString) else {
            ErrorLogger.shared.captureErrorEvent(
                message: "Couldn't create attachment URL",
                tags: ["reteno.attachment_url": urlString]
            )
            completionHandler(nil)
            return
        }
        
        session.downloadTask(with: url, completionHandler: { temporaryLocation, response, error in
            if let error = error {
                ErrorLogger.shared.capture(error: error)
            }
            var suggestedFilename = response?.suggestedFilename
            suggestedFilename = suggestedFilename == "unknown" ? UUID().uuidString : suggestedFilename
            
            guard
                let fileName = suggestedFilename,
                let localURL = temporaryLocation
            else {
                ErrorLogger.shared.captureErrorEvent(
                    message: "Couldn't download attachment",
                    tags: ["reteno.attachment_url": urlString]
                )
                completionHandler(nil)
                return
            }
            
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString + fileName)
            do {
                try FileManager.default.moveItem(at: localURL, to: fileURL)
            } catch {
                ErrorLogger.shared.capture(error: error)
                Logger.log("Failed to move file: \(error.localizedDescription)", eventType: .error)
                completionHandler(nil)
                return
            }
            // Create the notification attachment from the file
            do {
                let attachment = try UNNotificationAttachment(identifier: fileName, url: fileURL, options: nil)
                completionHandler(attachment)
            } catch {
                ErrorLogger.shared.capture(error: error)
                Logger.log("Failed to create attachment: \(error.localizedDescription)", eventType: .error)
                completionHandler(nil)
            }
        }).resume()
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
