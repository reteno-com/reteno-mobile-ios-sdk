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
    private var isAnonymous = false
    
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
    
    func generateId() -> String {
        UUID().uuidString
    }
    
    func updateIsAnonymous(_ isAnonymous: Bool) {
        self.isAnonymous = isAnonymous
    }
    
    func saveUser() {
        if isAnonymous {
            if !user.firstName.isEmpty || !user.lastName.isEmpty {
                let attributes = AnonymousUserAttributes(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    timeZone: TimeZone.current.identifier
                )
                Reteno.updateAnonymousUserAttributes(userAttributes: attributes)
            }
        } else {
            let attributes: UserAttributes? = {
                guard
                    !user.phone.isEmpty
                    || !user.email.isEmpty
                    || !user.firstName.isEmpty
                    || !user.lastName.isEmpty
                else { return nil }
                
                return .init(phone: user.phone, email: user.email, firstName: user.firstName, lastName: user.lastName)
            }()
            Reteno.updateUserAttributes(externalUserId: user.id, userAttributes: attributes)
        }
        
        navigationHandler.backToMain()
    }
    
}
