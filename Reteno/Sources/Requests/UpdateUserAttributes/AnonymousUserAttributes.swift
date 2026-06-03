//
//  AnonymousUserAttributes.swift
//  Reteno
//
//  Created by Anna Sahaidak on 06.02.2023.
//

import Foundation

public struct AnonymousUserAttributes: Codable {
    
    let firstName: String?
    let lastName: String?
    let languageCode: String?
    let timeZone: String?
    let marketId: String?
    let address: Address?
    let fields: [UserCustomField]
    
    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        languageCode: String? = nil,
        timeZone: String? = TimeZone.current.identifier,
        marketId: String? = nil,
        address: Address? = nil,
        fields: [UserCustomField] = []
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.languageCode = languageCode
        self.timeZone = timeZone
        self.marketId = marketId
        self.address = address
        self.fields = fields
    }
        
}
