//
//  DeepLinksProcessor.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 25.09.2022.
//

import UIKit

struct DeepLinksProcessor {
    
    @available(iOSApplicationExtension, unavailable)
    static func processLinks(wrappedUrl: URL?, rawURL: URL?) {
        guard let url = rawURL else { return }
        
        if let wrappedUrl = wrappedUrl {
            let service = SendingServiceBuilder.buildServiceWithEmptyURL()
            service.registerLinkClick(wrappedUrl.absoluteString)
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
