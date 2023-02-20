//
//  SentryHelper.swift
//  
//
//  Created by Serhii Prykhodko on 17.10.2022.
//

import Sentry

struct SentryHelper {
    
    private init() {}
    
    static func capture(error: Error) {
        let hub = prepareHub()
        hub?.capture(error: error)
    }
    
    static func capture(exeption: NSException) {
        let hub = prepareHub()
        hub?.capture(exception: exeption)
    }
    
    static func captureLog(title: String, count: Int) {
        let hub = prepareHub()
        let event = Sentry.Event(level: SentryLevel.info)
        event.message = SentryMessage(formatted: "Removed \(title): - \(count)")
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), title]
        hub?.capture(event: event)
    }
    
    static func captureItems(_ items: [Groupable], title: String, tagTitle: String) {
        let hub = prepareHub()
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
            hub?.capture(event: event)
        }
    }
    
    static func captureWarningEvent(message: String, tags: [String: String]? = nil) {
        let hub = prepareHub()
        let event = Sentry.Event(level: SentryLevel.warning)
        event.message = SentryMessage(formatted: message)
        event.fingerprint = [BundleIdHelper.getMainAppBundleId(), message]
        event.tags = tags
        hub?.capture(event: event)
    }
    
    static private func prepareHub() -> SentryHub? {
        do {
            let options = try Sentry.Options(
                dict: ["dsn": "https://699db07fec57455e964892ba10da106f@sentry.reteno.com/4504043420450816"]
            )
            
            // Features turned off by default, but worth checking out
            options.enableAppHangTracking = true
            options.enableFileIOTracking = true
            
            let client = Client(options: options)
            let hub = SentryHub(client: client, andScope: Scope())
            hub.scope.setTags(
                [
                    "reteno.sdk_version": "\(Reteno.version)",
                    "reteno.device_id": DeviceIdHelper.deviceId() ?? "",
                    "reteno.bundle_id": BundleIdHelper.getMainAppBundleId()
                ]
            )
            
            return hub
        } catch {
            Logger.log(error.localizedDescription, eventType: .error)
            return nil
        }
    }
    
}
