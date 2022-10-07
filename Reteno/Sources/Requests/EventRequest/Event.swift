//
//  Event.swift
//  Reteno
//
//  Created by Anna Sahaidak on 01.10.2022.
//

import Foundation

public struct Event {
    
    public struct Parameter {
        
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
