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
    
    // MARK: Multi-account
    
    var isMultiAccountEnabled: Bool {
        model.isMultiAccountEnabled
    }
    
    func setMultiAccountEnabled(_ isEnabled: Bool) {
        model.setMultiAccountEnabled(isEnabled)
    }
    
    func openAccounts() {
        model.openAccounts()
    }
    
    /// Human-readable description of the device id the SDK currently reports with.
    func currentAccountDescription() -> String {
        guard model.isMultiAccountEnabled else {
            return NSLocalizedString("createProfile_screen.multiAccount.hint.disabled", comment: "")
        }
        guard let suffix = model.currentAccountSuffix() else {
            return NSLocalizedString("createProfile_screen.multiAccount.hint.noAccount", comment: "")
        }
        
        return String(format: NSLocalizedString("createProfile_screen.multiAccount.hint.active", comment: ""), suffix)
    }
    
    // MARK: Profile
    
    var storedProfile: StoredProfile? {
        model.storedProfile
    }
    
    func updateShouldClearMarketId(_ shouldClear: Bool) {
        model.updateShouldClearMarketId(shouldClear)
    }
    
    func updateIsAnonymous(_ isAnonymous: Bool) {
        model.updateIsAnonymous(isAnonymous)
    }
    
    func updateIsMarketingPushEnabled(_ isEnabled: Bool) {
        model.updateIsMarketingPushEnabled(isEnabled)
    }
    
    func saveUser(_ user: User) {
        model.saveUser(user)
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
