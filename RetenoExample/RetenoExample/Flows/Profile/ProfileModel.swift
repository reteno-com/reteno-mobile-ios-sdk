//
//  ProfileModel.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation
import Reteno

protocol ProfileModelNavigationHandler {
    
    func backToMain()
    
}

final class ProfileModel {
    
    private var user: User
    
    private let navigationHandler: ProfileModelNavigationHandler
    
    init(user: User = User(), navigationHandler: ProfileModelNavigationHandler) {
        self.user = user
        self.navigationHandler = navigationHandler
    }
    
    func updateExternalId(_ externalId: String?) {
        guard let externalId = externalId else { return }
        
        user.id = externalId
    }
    
    func updateFirstName(_ firstName: String) {
        user.firstName = firstName
    }
    
    func updateLastName(_ lastName: String) {
        user.lastName = lastName
    }
    
    func updatePhone(_ phone: String) {
        user.phone = phone
    }
    
    func updateEmail(_ email: String) {
        user.email = email
    }
    
    func saveUser() {
        let attributes = UserAttributes(
            phone: user.phone.isEmpty ? nil : user.phone,
            email: user.email.isEmpty ? nil : user.email,
            firstName: user.firstName.isEmpty ? nil : user.firstName,
            lastName: user.lastName.isEmpty ? nil : user.lastName
        )

        Reteno.updateUserAttributes(externalUserId: user.id, userAttributes: attributes)
        navigationHandler.backToMain()
    }
    
}
