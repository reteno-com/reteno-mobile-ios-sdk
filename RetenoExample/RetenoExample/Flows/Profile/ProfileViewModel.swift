//
//  ProfileViewModel.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 06.10.2022.
//

import Foundation

final class ProfileViewModel {
    
    private let model: ProfileModel
    
    init(model: ProfileModel) {
        self.model = model
    }
    
    func updateExternalId(_ externalId: String?) {
        model.updateExternalId(externalId)
    }
    
    func updateFirstName(_ firstName: String) {
        model.updateFirstName(firstName)
    }
    
    func updateLastName(_ lastName: String) {
        model.updateLastName(lastName)
    }
    
    func updatePhone(_ phone: String) {
        model.updatePhone(phone)
    }
    
    func updateEmail(_ email: String) {
        model.updateEmail(email)
    }
    
    func generateId() -> String {
        model.generateId()
    }
    
    func saveUser() {
        model.saveUser()
    }
    
}
