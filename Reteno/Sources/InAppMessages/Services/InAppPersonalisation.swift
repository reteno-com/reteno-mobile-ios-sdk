//
//  InAppPersonalisation.swift
//  Reteno
//
//  Created by George Farafonov on 19.08.2026.
//

import Foundation

struct InAppPersonalisation {
    
    static let supportedKeys: Set<String> = [
        "phone",
        "email",
        "firstName",
        "lastName",
        "languageCode",
        "timeZone",
        "marketId",
        "region",
        "town",
        "address",
        "postcode"
    ]
    
    private static let placeholderRegex = try? NSRegularExpression(pattern: #"\$\{([a-zA-Z_][a-zA-Z0-9_]*)\}"#)
    
    private let values: [String: String]
    
    init(values: [String: String]) {
        self.values = values
    }
    
    init(storage: KeyValueStorage = StorageBuilder.build()) {
        self.init(values: Self.values(from: storage))
    }
    
    func prepareHTML(_ html: String, for message: InApp) -> String {
        let hasServerAssignedIid = (message as? InAppContent)?.hasServerAssignedIid == true
        let model = hasServerAssignedIid ? message.model : apply(to: message.model)
        return html
            .replacingOccurrences(of: "${documentModel}", with: model)
            .replacingOccurrences(of: "${personalisation}", with: message.personalisation ?? "{}")
    }

    func apply(to content: String) -> String {
        guard content.contains("${"), let regex = Self.placeholderRegex else { return content }
        
        let content = content as NSString
        let matches = regex.matches(in: content as String, range: NSRange(location: 0, length: content.length))
        guard matches.isNotEmpty else { return content as String }
        
        var result = ""
        var resolvedLength = 0
        for match in matches {
            let key = content.substring(with: match.range(at: 1))
            guard Self.supportedKeys.contains(key) else { continue }
            
            let precedingRange = NSRange(location: resolvedLength, length: match.range.location - resolvedLength)
            result += content.substring(with: precedingRange)
            result += Self.jsonEscaped(values[key] ?? "")
            resolvedLength = match.range.upperBound
        }
        result += content.substring(from: resolvedLength)
        
        return result
    }
    
    private static func values(from storage: KeyValueStorage) -> [String: String] {
        var values = storage.getCachedUser()?.userAttributes?.personalisationValues() ?? [:]
        values["email"] = values["email"] ?? ExternalUserDataHelper.getEmail()
        values["phone"] = values["phone"] ?? ExternalUserDataHelper.getPhone()
        
        return values
    }
    
    private static func jsonEscaped(_ value: String) -> String {
        var result = ""
        result.reserveCapacity(value.unicodeScalars.count)
        
        for scalar in value.unicodeScalars {
            switch scalar {
            case "\"": result += "\\\""
            case "\\": result += "\\\\"
            case "\n": result += "\\n"
            case "\r": result += "\\r"
            case "\t": result += "\\t"
            case "<": result += "\\u003c"
            case ">": result += "\\u003e"
                
            default:
                if scalar.value < 0x20 {
                    result += String(format: "\\u%04x", scalar.value)
                } else {
                    result.unicodeScalars.append(scalar)
                }
            }
        }
        
        return result
    }
    
}

extension UserAttributes {
    
    func personalisationValues() -> [String: String] {
        var values: [String: String] = [:]
        
        values["phone"] = phone
        values["email"] = email
        values["firstName"] = firstName
        values["lastName"] = lastName
        values["languageCode"] = languageCode
        values["timeZone"] = timeZone
        values["marketId"] = marketId
        
        for (key, value) in address?.toJSON() ?? [:] {
            values[key] = value as? String
        }
        
        return values
    }
    
}
