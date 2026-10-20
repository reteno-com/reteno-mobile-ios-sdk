//
//  MultiAccountStorage.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

/// An account added on this device in multi-account mode.
struct SavedAccount: Codable, Equatable {
    
    let externalUserId: String
    /// Custom suffix passed at save time; `nil` means the SDK uses `externalUserId`.
    let accountSuffix: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    
    /// The suffix the SDK puts into the device id for this account (`<baseDeviceId>:<suffix>`).
    var resolvedSuffix: String { accountSuffix ?? externalUserId }
    
    var displayName: String? {
        let name = [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        
        return name.isEmpty ? nil : name
    }
    
}

/// Example-app side state of the multi-account demo. The SDK itself only knows the current device id.
enum MultiAccountStorage {
    
    private static let accountsKey = "MultiAccount.SavedAccounts"
    private static let isEnabledKey = "MultiAccount.IsEnabled"
    
    static var isEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: isEnabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: isEnabledKey) }
    }
    
    static func accounts() -> [SavedAccount] {
        guard let data = UserDefaults.standard.data(forKey: accountsKey) else { return [] }
        
        return (try? JSONDecoder().decode([SavedAccount].self, from: data)) ?? []
    }
    
    /// Adds `account` to the end of the list or replaces an existing entry with the same external user id in place.
    static func upsert(_ account: SavedAccount) {
        var accounts = accounts()
        if let index = accounts.firstIndex(where: { $0.externalUserId == account.externalUserId }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
        save(accounts)
    }
    
    static func remove(_ account: SavedAccount) {
        save(accounts().filter { $0.externalUserId != account.externalUserId })
    }
    
    private static func save(_ accounts: [SavedAccount]) {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        
        UserDefaults.standard.set(data, forKey: accountsKey)
    }
    
}
