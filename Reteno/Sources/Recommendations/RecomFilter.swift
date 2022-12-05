//
//  RecomFilter.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Foundation

public struct RecomFilter {
    
    let name: String
    let values: [String]
    
    public init(name: String, values: [String]) {
        self.name = name
        self.values = values
    }
    
    func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        json["name"] = name
        json["values"] = values
        
        return json
    }
    
}
