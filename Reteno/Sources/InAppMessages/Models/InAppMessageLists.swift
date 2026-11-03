//
//  InAppMessageLists.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppMessageLists: Codable {
    let messages: [Message]

    private enum CodingKeys: String, CodingKey { case messages }
    private struct Entry: Decodable {
        let value: Message?
        init(from decoder: Decoder) throws { value = try? Message(from: decoder) }
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decode([Entry].self, forKey: .messages).compactMap { $0.value }
    }
}

protocol ConditionalValue: Codable, Encodable { }

struct Message: Codable {
    let messageId: Int
    let messageInstanceId: Int
    
    var inWorkflow: Bool? = nil
    var iid: String? = nil
    var expiresAt: String? = nil

    var isWorkflow: Bool { inWorkflow == true }
    var executionKey: String { isWorkflow ? "workflow:" + (iid ?? "") : "rules:\(messageId)" }

    func isAvailable(at date: Date) -> Bool {
        guard isWorkflow else { return true }
        guard let iid, UUID(uuidString: iid) != nil, let expiresAt,
              let deadline = WorkflowDate.parse(expiresAt) else { return false }
        return date < deadline
    }

    let displayRules: DisplayRules

    struct DisplayRules: Codable {
        let frequency: Frequency
        let async: Async
        let targeting: Targeting
        let schedule: Schedule
        var workflowSupported: Bool = true

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            frequency = try container.decode(Frequency.self, forKey: .frequency)
            async = try container.decode(Async.self, forKey: .async)
            targeting = try container.decode(Targeting.self, forKey: .targeting)
            schedule = try container.decode(Schedule.self, forKey: .schedule)
            let raw = try decoder.container(keyedBy: JSONCodingKeys.self).decode([String: Any].self)
            let known: Set<String> = ["FREQUENCY", "ASYNC", "TARGETING", "SCHEDULE"]
            workflowSupported = (try container.decodeIfPresent(Bool.self, forKey: .workflowSupported) ?? true) && !raw.contains { !known.contains($0.key) && ($0.value as? [String: Any])?["enabled"] as? Bool == true }
            if let asyncRules = raw["ASYNC"] as? [String: Any] {
                workflowSupported = workflowSupported && !asyncRules.contains {
                    $0.key != "IS_IN_SEGMENT" && ($0.value as? [String: Any])?["enabled"] as? Bool == true
                }
            }
            if let targeting = raw["TARGETING"] as? [String: Any], targeting["enabled"] as? Bool == true,
               let schema = targeting["schema"] as? [String: Any],
               let exclude = schema["exclude"] as? [String: Any],
               let groups = exclude["groups"] as? [Any], !groups.isEmpty {
                workflowSupported = false
            }
        }

        func nonFrequencyRulesData() -> Data? {
            guard let encoded = try? JSONEncoder().encode(self),
                  var rules = (try? JSONSerialization.jsonObject(with: encoded)) as? [String: Any] else { return nil }
            rules.removeValue(forKey: "FREQUENCY")
            return try? JSONSerialization.data(withJSONObject: rules, options: .sortedKeys)
        }

        enum CodingKeys: String, CodingKey {
            case frequency = "FREQUENCY", async = "ASYNC", targeting = "TARGETING", schedule = "SCHEDULE"
            case workflowSupported = "_sdkWorkflowSupported"
        }
    }
}

struct Frequency: Codable {
    let type: String
    let enabled: Bool

    let predicates: [Predicate]
    
    struct Predicate: Codable {
        let name: PredicateName
        let isActive: Bool
        
        let params: FrequencyBaseParams?
        
        enum CodingKeys: String, CodingKey {
            case name, isActive, params
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.name = (try? container.decode(PredicateName.self, forKey: Frequency.Predicate.CodingKeys.name)) ?? .unknown
            self.isActive = try container.decode(Bool.self, forKey: Frequency.Predicate.CodingKeys.isActive)
            if name == .timesPerTimeUnit {
                self.params = try? container.decode(FrequencyPerUnitParams.self, forKey: .params)
            } else {
                self.params = try? container.decode(FrequencyParams.self, forKey: .params)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(isActive, forKey: .isActive)
            if name == .timesPerTimeUnit {
                try? container.encode(params as? FrequencyPerUnitParams, forKey: .params)
            } else {
                try? container.encode(params as? FrequencyParams, forKey: .params)
            }
        }
    }
}

struct Async: Codable {
    let segment: Segment

    struct Segment: Codable {
        let enabled: Bool
        let segmentId: Int?
    }

    enum CodingKeys: String, CodingKey {
        case segment = "IS_IN_SEGMENT"
    }
}

struct Targeting: Codable {
    let schema: Schema?

    let type: String
    let enabled: Bool
    
    struct Schema: Codable {
        let exclude: Exclude
        let include: Include
        
        struct Exclude: Codable {
            let relation: String
        }

        struct Include: Codable {
            let groups: [Group?]
            let relation: String
            
            struct Group: Codable {
                let relation: String
                let conditions: [Condition]?
            }
        }
    }
}

struct Schedule: Codable {
    let enabled: Bool
    let predicates: [SchedulePredicate]
    
    struct SchedulePredicate: Codable {
        let name: PredicateName?
        let isActive: Bool
        let params: ScheduleParams?
        
        enum CodingKeys: String, CodingKey {
            case name, isActive, params
        }
        
        enum PredicateName: String, Codable {
            case showAfter = "SHOW_AFTER", hideAfter = "HIDE_AFTER",
                 specificDaysAndTime = "SPECIFIC_DAYS_AND_TIME"
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try? container.decode(PredicateName.self, forKey: .name)
            self.isActive = try container.decode(Bool.self, forKey: .isActive)
            
            switch name {
            case .showAfter, .hideAfter:
                self.params = try? container.decode(DateParams.self, forKey: .params)
            case .specificDaysAndTime:
                self.params = try? container.decode(SpecificDate.self, forKey: .params)
            default:
                self.params = nil
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try? container.encode(name, forKey: .name)
            try container.encode(isActive, forKey: .isActive)
            
            if name == .showAfter || name == .hideAfter {
                try? container.encode(params as? DateParams, forKey: .params)
            } else if name == .specificDaysAndTime {
                try? container.encode(params as? SpecificDate, forKey: .params)
            }
        }
        
        struct DateParams: ScheduleParams {
            let date: String
            let timeZone: String?
        }
        
        struct SpecificDate: ScheduleParams {
            let days: [String]
            let timeZone: String?
            let time: SpecificTime
            
            struct SpecificTime: Codable {
                let from: Time
                let to: Time
                
                struct Time: Codable {
                    let hours: String
                    let minutes: String
                }
            }
        }
    }
}

struct Condition: Codable {
    struct Operand: Codable {
        let name: OperandName?
        
        enum OperandName: String, Codable {
            case user = "USER", event = "EVENT"
        }
    }

    let operand: Operand
    let `operator`: ConditionOperator?
                                
    let values: [ConditionalValue]?
    var workflowSupported = true

    enum CodingKeys: String, CodingKey {
        case operand, `operator` = "operator", values
        case workflowSupported = "_sdkWorkflowSupported"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operand = try container.decode(Condition.Operand.self, forKey: .operand)
        self.operator = try? container.decode(Condition.ConditionOperator.self, forKey: .operator)
        let rawOperator = try container.decodeIfPresent(String.self, forKey: .operator)
        self.workflowSupported = (try container.decodeIfPresent(Bool.self, forKey: .workflowSupported) ?? true) &&
            (rawOperator == nil || self.operator != nil || (operand.name == .event && rawOperator == "AFTER_EVENT"))
        if operand.name == .user {
            self.values = try? container.decodeIfPresent([Condition.Value].self, forKey: .values)
        } else if operand.name == .event {
            self.values = try? container.decodeIfPresent([Condition.EventValue].self, forKey: .values)
        } else {
            self.values = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(workflowSupported, forKey: .workflowSupported)
        try container.encode(self.operand, forKey: .operand)
        try? container.encode(self.operator, forKey: .operator)
        if operand.name == .user {
            try? container.encode(values as? [Condition.Value], forKey: .values)
        } else if operand.name == .event {
            try? container.encode(values as? [Condition.EventValue], forKey: .values)
        }
    }
    
    struct Value: ConditionalValue {
        let unit: UnitValue
        let amount: Int?
    }
    
    struct EventValue: ConditionalValue {
        let event: String
        let parameters: EventParameters
        
        struct EventParameters: Codable {
            let relation: String
            let values: [Parameters]
            
            struct Parameters: Codable {
                let name: String
                let `operator`: ParametersOperator?
                let value: [String]
                
                enum ParametersOperator: String, Codable {
                    case contains = "CONTAINS", equals = "EQUALS", doesNotEqual = "DOES_NOT_EQUAL", startsWith = "STARTS_WITH", containsOneOf = "CONTAINS_ONE_OF", endsWith = "ENDS_WITH", regex = "REG_EX"
                }
            }
        }
    }
    
    enum ConditionOperator: String, Codable {
        case timeSpentInApp = "TIME_SPENT_IN_APP", newUser = "NEW_USER"
    }
}

protocol FrequencyBaseParams: Codable, Encodable {}
protocol ScheduleParams: Codable, Encodable {
    var timeZone: String? { get }
}

struct FrequencyParams: FrequencyBaseParams {
    let unit: UnitValue
    let amount: Int
}

struct FrequencyPerUnitParams: FrequencyBaseParams {
    let unit: UnitValue
    let count: Int
}

enum PredicateName: String, Codable {
    case noLimit = "NO_LIMIT", oncePerApp = "ONCE_PER_APP",
         oncePerSession = "ONCE_PER_SESSION", minInterval = "MIN_INTERVAL",
         timesPerTimeUnit = "TIMES_PER_TIME_UNIT", unknown
}

enum UnitValue: String ,Codable {
    case seconds = "SECOND", minute = "MINUTE", hour = "HOUR", day = "DAY", week = "WEEK"
}
