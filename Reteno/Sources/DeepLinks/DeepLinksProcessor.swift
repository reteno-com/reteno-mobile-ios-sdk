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
        if let wrappedUrl = wrappedUrl {
            storage.appendLink(StorableLink(value: wrappedUrl.absoluteString, date: Date()))
            scheduler.forcePushEvents()
        }
        let linkInfo: LinkHandler = .init(
            url: rawURL,
            customData: customData,
            source: isInAppMessageLink ? .inAppMessage : .pushNotification
        )
        
        if let linkHandler = Reteno.linkHandler {
            linkHandler(linkInfo)
        } else {
            Self.openIfAvalable(rawURL)
        }
    }
    
    @available(iOSApplicationExtension, unavailable)
    private static func openIfAvalable(
        _ url: URL?
    ) {
        if let url = url,
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil
            )
        } else {
            Logger.log(
                "`Reteno.linkHandler` hasn't implemented, parameter: rawURL is empty, event can NOT be handled",
                eventType: .warning
            )
        }
    }
}
