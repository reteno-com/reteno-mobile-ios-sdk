//
//  JSONInitable.swift
//  
//
//  Created by Anna Sahaidak on 10.11.2022.
//

import Foundation

public protocol JSONInitable: Decodable {

    init?(json: [String: Any]) throws

}

public extension JSONInitable {
    
    init?(json: [String: Any]) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
    
}
