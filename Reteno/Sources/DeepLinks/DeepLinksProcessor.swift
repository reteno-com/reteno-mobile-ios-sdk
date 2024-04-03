//
//  DeepLinksProcessor.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 25.09.2022.
//

import UIKit

struct DeepLinksProcessor {
    
    @available(iOSApplicationExtension, unavailable)
    static func processLinks(
        wrappedUrl: URL?,
        rawURL: URL?,
        customData: [String: Any]? = nil,
        isInAppMessageLink: Bool,
        storage: KeyValueStorage = StorageBuilder.build(),
        scheduler: EventsSenderScheduler = Reteno.senderScheduler
    ) {
        guard let url = rawURL else { return }
        
        if let wrappedUrl = wrappedUrl {
            storage.appendLink(StorableLink(value: wrappedUrl.absoluteString, date: Date()))
            scheduler.forcePushEvents()
        }
        let linkInfo: LinkHandler = .init(
            url: url,
            customData: customData,
            source: isInAppMessageLink ? .inAppMessage : .pushNotification
        )
        
        Reteno.linkHandler?(linkInfo) ?? UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
