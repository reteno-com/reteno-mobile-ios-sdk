//
//  RequestIdentity.swift
//  Reteno
//

import Foundation

/// Device id and external user id a queued request belongs to.
///
/// Queued data (events, user updates, device upserts, recom events, inbox opened ids) captures the identity
/// at the moment it is created. Without it, data collected for one multi-account account and sent after the
/// switch would be attributed to the next account, because requests read the device id when they are built.
struct RequestIdentity: Codable, Hashable {
    
    let deviceId: String
    let externalUserId: String?
    
    static var current: RequestIdentity {
        RequestIdentity(deviceId: DeviceIdHelper.deviceId() ?? "", externalUserId: ExternalUserIdHelper.getId())
    }
    
    /// Identity to send data captured under `identity` with.
    ///
    /// Data captured under the current device id is sent with the current identity, exactly as before identities
    /// were captured (e.g. events logged before `externalUserId` was set still go out with it). Only data captured
    /// under another device id - a previous multi-account account - keeps its own identity. `nil` (data stored
    /// by an older SDK version) is sent with the current identity.
    static func resolved(_ identity: RequestIdentity?) -> RequestIdentity {
        let current = RequestIdentity.current
        guard let identity, identity.deviceId != current.deviceId else { return current }
        
        return identity
    }
    
    static func provider(for identity: RequestIdentity?) -> () -> RequestIdentity {
        guard let identity else { return { .current } }
        
        return { resolved(identity) }
    }
    
    var isCurrent: Bool {
        deviceId == DeviceIdHelper.deviceId() ?? ""
    }
    
}
