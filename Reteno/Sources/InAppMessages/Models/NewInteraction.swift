//
//  NewInteraction.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation
import CommonCrypto

enum NewInteractionStatus: String, Codable {
    case opened = "OPENED", clicked = "CLICKED", failed = "FAILED"
}

struct NewInteraction: Codable {
    let id: String
    let time: Date
    let messageInstanceId: Int
    let status: NewInteractionStatus
    let statusDescription: String?
    var inWorkflow: Bool = false
    let action: NotificationStatus.Action?
    
    init(
        id: String = UUID().uuidString,
        time: Date,
        messageInstanceId: Int,
        status: NewInteractionStatus,
        statusDescription: String?,
        action: NotificationStatus.Action? = nil
    ) {
        self.id = id
        self.time = time
        self.messageInstanceId = messageInstanceId
        self.status = status
        self.statusDescription = statusDescription
        self.action = action
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        
        if inWorkflow { json["inWorkflow"] = true }
        json["iid"] = id
        json["time"] = inWorkflow ? WorkflowDate.format(time) : DateFormatter.baseBEDateFormatter.string(from: time)
        json["messageInstanceId"] = messageInstanceId
        json["status"] = status.rawValue
        
        if inWorkflow, let action {
            var payload = ["type": action.type]
            payload["targetComponentId"] = action.targetComponentId
            payload["url"] = action.url
            json["action"] = payload
        }
        if let statusDescription = statusDescription {
            json["statusDescription"] = statusDescription
        }
 
        return json
    }
    
}

// The digest scopes local state without retaining another copy of the access key.
enum WorkflowContext {
    struct Snapshot {
        let id: String
        let headers: [String: String]

        init(apiKey: String, identity: RequestIdentity, email: String?, phone: String?) {
            let values = [apiKey, identity.deviceId, identity.externalUserId ?? "", email ?? "", phone ?? ""]
            let data = (try? JSONEncoder().encode(values)) ?? Data()
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest) }
            id = digest.map { String(format: "%02x", $0) }.joined()
            headers = ["X-Reteno-Access-Key": apiKey, "X-Reteno-Device-ID": identity.deviceId]
        }
    }

    static func capture() -> Snapshot {
        Snapshot(apiKey: ApiKeyHelper.getApiKey(), identity: .current,
                 email: ExternalUserDataHelper.getEmail(), phone: ExternalUserDataHelper.getPhone())
    }

    static var headers: [String: String] { capture().headers }
    static var current: String { capture().id }
}

enum WorkflowDate {
    static func parse(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: text) ?? ISO8601DateFormatter().date(from: text)
    }

    static func format(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}

struct QueuedInAppInteraction: Codable {
    // Local queue identity only; never sent to the backend.
    let id: String
    let context: String
    let interaction: NewInteraction
    var attempts: Int = 0
    var nextAttempt: Date
}

struct WorkflowState: Codable {
    var pendingRegistrationContext: String? = nil
    var shown: [String: Set<String>] = [:]
    var deadlines: [String: [String: String]] = [:]
    var observations: [QueuedInAppInteraction] = []
}
