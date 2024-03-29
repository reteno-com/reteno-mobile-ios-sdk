//
//  User.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

struct User {
    
    var id: String
    var firstName: String?
    var lastName: String?
    var phone: String?
    var email: String?
    
    init(id: String = "", firstName: String? = nil, lastName: String? = nil, phone: String? = nil, email: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
    
}
