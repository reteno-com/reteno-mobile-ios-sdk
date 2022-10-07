//
//  AdvertisingIdHelper.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 28.09.2022.
//

import AdSupport
import AppTrackingTransparency

struct AdvertisingIdHelper {
    
    private init() {}
    
    static func getAdvertisingId() -> String? {
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus == .authorized {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return nil
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                return nil
            }
        }
    }
    
}
