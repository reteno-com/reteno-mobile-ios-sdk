//
//  Event.swift
//  Reteno
//
//  Created by Anna Sahaidak on 01.10.2022.
//

import Foundation

public struct Event: Codable {
    
    public struct Parameter: Codable {
                
        let name: String
        let value: String
        
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
        
    }
    
    let eventTypeKey: String
    let date: Date
    let parameters: [Parameter]
    let id: String
    
    init(eventTypeKey: String, date: Date, parameters: [Event.Parameter]) {
        self.eventTypeKey = eventTypeKey
        self.date = date
        self.parameters = parameters
        self.id = UUID().uuidString
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        json["eventTypeKey"] = eventTypeKey
        json["occurred"] = DateFormatter.baseBEDateFormatter.string(from: date)
        if !parameters.isEmpty {
            json["params"] = parameters.map { ["name": $0.name, "value": $0.value] }
        }
        
        return json
    }
    
}

// MARK: ExpirableData

extension Event: ExpirableData {
    
    static var logTitle: String { "Removed events" }
    
}

// MARK: Groupable

extension Event: Groupable {
    
    static var keyTitle: String { "event_type_key" }
    var key: String { eventTypeKey }
    
}
