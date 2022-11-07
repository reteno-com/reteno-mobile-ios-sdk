//
//  DeepLinksProcessor.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 25.09.2022.
//

import UIKit

struct DeepLinksProcessor {
    
    @available(iOSApplicationExtension, unavailable)
    static func process(notification: RetenoUserNotification) {
        guard let url = notification.rawLink else { return }
        
        if let wrappedUrl = notification.link {
            let service = SendingServiceBuilder.buildServiceWithEmptyURL()
            service.registerLinkClick(wrappedUrl.absoluteString)
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
