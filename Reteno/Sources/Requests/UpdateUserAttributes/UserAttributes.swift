//
//  UserAttributes.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

public struct UserAttributes: Codable, Equatable {
    
    let phone: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let languageCode: String?
    let timeZone: String?
    let address: Address?
    let fields: [UserCustomField]
    
    public init(
        phone: String? = nil,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        languageCode: String? = nil,
        timeZone: String? = TimeZone.current.identifier,
        address: Address? = nil,
        fields: [UserCustomField] = []
    ) {
        self.phone = phone
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.languageCode = languageCode
        self.timeZone = timeZone
        self.address = address
        self.fields = fields
    }
    
    func toJSON() -> [String: Any]? {
        var tempJSON: [String: Any] = [:]
        
        tempJSON["phone"] = phone
        tempJSON["email"] = email
        tempJSON["firstName"] = firstName
        tempJSON["lastName"] = lastName
        tempJSON["languageCode"] = languageCode
        tempJSON["timeZone"] = timeZone
        tempJSON["address"] = address?.toJSON()
        
        let tempFields = fields.map { $0.toJSON() }
        tempJSON["fields"] = tempFields.isEmpty ? nil : tempFields
        
        return tempJSON.isEmpty ? nil : tempJSON
    }
    
    public static func == (lhs: UserAttributes, rhs: UserAttributes) -> Bool {
        lhs.phone == rhs.phone && lhs.email == rhs.email && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.languageCode == rhs.languageCode && lhs.timeZone == rhs.timeZone && lhs.address == rhs.address && lhs.fields == rhs.fields
    }
}
