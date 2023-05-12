//
//  SentryHelper.swift
//  
//
//  Created by Serhii Prykhodko on 17.10.2022.
//

import Sentry

final class SentryHelper {
    
    static let shared = SentryHelper()
    
    private let hub: SentryHub
    
    private init() {
        let options = Options()
        options.dsn = "https://699db07fec57455e964892ba10da106f@sentry.reteno.com/4504043420450816"
        options.enableAppHangTracking = true
        options.enableFileIOTracing = true
        let client = SentryClient(options: options)
        let hub = SentryHub(client: client, andScope: Scope())
        hub.configureScope { scope in
            scope.setTags(
                [
                    "reteno.sdk_version": "\(Reteno.version)",
                    "reteno.device_id": DeviceIdHelper.deviceId() ?? "",
                    "reteno.bundle_id": BundleIdHelper.getMainAppBundleId()
                ]
            )
        }
        self.hub = hub
    }
    
    static func capture(error: Error) {
        shared.hub.capture(error: error)
    }
    
    static func capture(exeption: NSException) {
        shared.hub.capture(exception: exeption)
    }
    
    static func captureLog(title: String, count: Int) {
        let event = Sentry.Event(level: SentryLevel.info)
        event.message = SentryMessage(formatted: "Removed \(title): - \(count)")
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), title]
        shared.hub.capture(event: event)
    }
    
    static func captureItems(_ items: [Groupable], title: String, tagTitle: String) {
        let groupedItems = items.reduce(into: [String: [Groupable]]()) { result, item in
            if result[item.key].isNone {
                result[item.key] = []
            }
            result[item.key]?.append(item)
        }
        groupedItems.forEach {
            let event = Sentry.Event(level: SentryLevel.info)
            event.message = SentryMessage(formatted: "\(title)(\($0.key)) - \($0.value.count)")
            event.fingerprint = [BundleIdHelper.getMainAppBundleId(), title, $0.key]
            event.tags = [tagTitle: $0.key]
            shared.hub.capture(event: event)
        }
    }
    
    static func captureWarningEvent(message: String, tags: [String: String]? = nil) {
        let event = Sentry.Event(level: SentryLevel.warning)
        event.message = SentryMessage(formatted: message)
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), message]
        event.tags = tags
        shared.hub.capture(event: event)
    }
    
}
