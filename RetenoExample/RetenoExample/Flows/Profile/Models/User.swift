//
//  User.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation
import Reteno

struct User: Codable, Equatable {
    
    var id: String
    var firstName: String?
    var lastName: String?
    var phone: String?
    var email: String?
    var marketId: String?
    
    init(
        id: String = "",
        firstName: String? = nil,
        lastName: String? = nil,
        phone: String? = nil,
        email: String? = nil,
        marketId: String? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
        self.marketId = marketId
    }
    
    /// SDK attributes for this user, `nil` when there is nothing to send.
    func userAttributes(marketId: String?, fields: [UserCustomField] = []) -> UserAttributes? {
        guard phone != nil || email != nil || firstName != nil || lastName != nil || marketId != nil || !fields.isEmpty else {
            return nil
        }
        
        return UserAttributes(
            phone: phone,
            email: email,
            firstName: firstName,
            lastName: lastName,
            marketId: marketId,
            fields: fields
        )
    }
    
}
