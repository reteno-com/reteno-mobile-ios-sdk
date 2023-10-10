//
//  UserCustomField.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

public struct UserCustomField: Codable, Equatable {
    
    private let key: String
    private let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    func toJSON() -> [String: Any] {
        [
            "key": key,
            "value": value
        ]
    }
    
}
