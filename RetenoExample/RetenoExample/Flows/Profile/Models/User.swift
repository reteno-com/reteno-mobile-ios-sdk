//
//  User.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

struct User {
    
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    
    let id = UUID().uuidString
    
    init(firstName: String = "", lastName: String = "", phone: String = "", email: String = "") {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.email = email
    }
    
}
