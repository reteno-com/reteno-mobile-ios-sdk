//
//  InAppMessageLists.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppMessageLists: Codable {
    let messages: [Message]
}

protocol ConditionalValue: Codable, Encodable { }

struct Message: Codable {
    let messageId: Int
    let messageInstanceId: Int
    
    let displayRules: DisplayRules

    struct DisplayRules: Codable {
        let frequency: Frequency
        let async: Async
        let targeting: Targeting
        let schedule: Schedule
        
        enum CodingKeys: String, CodingKey {
            case frequency = "FREQUENCY", async = "ASYNC", targeting = "TARGETING", schedule = "SCHEDULE"
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
            self.name = try container.decode(PredicateName.self, forKey: Frequency.Predicate.CodingKeys.name)
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
    
    enum CodingKeys: String, CodingKey {
        case operand, `operator` = "operator", values
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operand = try container.decode(Condition.Operand.self, forKey: .operand)
        self.operator = try? container.decode(Condition.ConditionOperator.self, forKey: .operator)
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
                    case contains = "CONTAINS", equals = "EQUALS", startsWith = "STARTS_WITH", containsOneOf = "CONTAINS_ONE_OF", endsWith = "ENDS_WITH", regex = "REG_EX"
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
