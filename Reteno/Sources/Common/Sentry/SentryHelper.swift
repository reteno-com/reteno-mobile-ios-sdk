//
//  SentryHelper.swift
//  
//
//  Created by Serhii Prykhodko on 17.10.2022.
//

import Sentry

final class SentryHelper {
    
    static let shared = SentryHelper()
    
    private let hub: SentryHub?
    
    private init() {
        guard AnalyticModeHelper.isAnalyticModelOn() else {
            hub = nil
            return
        }
        
        let options = Options()
        options.dsn = "https://4d9bf85beb7443069b6882ba8ffdee24@sentry.reteno.com/4503999620841472"
        options.debug = true
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
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }
        
        shared.hub?.capture(error: error)
    }
    
    static func capture(exeption: NSException) {
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }

        shared.hub?.capture(exception: exeption)
    }
    
    static func captureLog(title: String, count: Int) {
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }
        
        let event = Sentry.Event(level: SentryLevel.info)
        event.message = SentryMessage(formatted: "Removed \(title): - \(count)")
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), title]
        shared.hub?.capture(event: event)
    }
    
    static func captureItems(_ items: [Groupable], title: String, tagTitle: String) {
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }

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
            shared.hub?.capture(event: event)
        }
    }
    
    static func captureWarningEvent(message: String, tags: [String: String]? = nil) {
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }

        let event = Sentry.Event(level: SentryLevel.warning)
        event.message = SentryMessage(formatted: message)
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), message]
        event.tags = tags
        shared.hub?.capture(event: event)
    }
    
    static func captureErrorEvent(message: String, tags: [String: String]? = nil) {
        guard AnalyticModeHelper.isAnalyticModelOn() else { return }

        let event = Sentry.Event(level: SentryLevel.error)
        event.message = SentryMessage(formatted: message)
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), message]
        event.tags = tags
        shared.hub?.capture(event: event)
    }
    
}
