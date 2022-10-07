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
        guard let url = notification.link else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
