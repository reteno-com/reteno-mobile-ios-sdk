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
    
    func updateIsAnonymous(_ isAnonymous: Bool) {
        model.updateIsAnonymous(isAnonymous)
    }
    
    func generateId() -> String {
        model.generateId()
    }
    
    func saveUser() {
        model.saveUser()
    }
    
    func getUnreadMessagesCount(completion: @escaping (Int) -> Void) {
        model.getUnreadMessagesCount { res in
            switch res {
            case .success(let count):
                completion(count)
            case .failure(let failure):
                print("Error fetching uread count: \(failure)")
            }
        }
    }
    
    func getMessages() {
        model.getMessages { res in
            switch res {
            case .success(let success):
                print(success.messages)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
