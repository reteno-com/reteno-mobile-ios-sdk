//
//  Address.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

public struct Address: Codable, Equatable {
    
    private let region: String?
    private let town: String?
    private let address: String?
    private let postcode: String?
    
    public init(region: String? = nil, town: String? = nil, address: String? = nil, postcode: String? = nil) {
        self.region = region
        self.town = town
        self.address = address
        self.postcode = postcode
    }
    
    func toJSON() -> [String: Any]? {
        var tempJSON: [String: Any] = [:]
        
        tempJSON["region"] = region
        tempJSON["town"] = town
        tempJSON["address"] = address
        tempJSON["postcode"] = postcode
        
        return tempJSON.isEmpty ? nil : tempJSON
    }
    
}
