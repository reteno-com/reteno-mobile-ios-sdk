//
//  AccountsListViewModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

final class AccountsListViewModel {
    
    struct Item {
        let title: String
        let subtitle: String
        let isActive: Bool
    }
    
    private(set) var items: [Item] = []
    
    private var accounts: [SavedAccount] = []
    private let model: AccountsListModel
    
    init(model: AccountsListModel) {
        self.model = model
    }
    
    func reload() {
        accounts = model.accounts()
        items = accounts.map { account in
            let suffix = String(
                format: NSLocalizedString("accounts_screen.cell.suffix", comment: ""),
                account.resolvedSuffix
            )
            let subtitle = [account.displayName, account.email, suffix].compactMap { $0 }.joined(separator: " · ")
            
            return Item(title: account.externalUserId, subtitle: subtitle, isActive: model.isActive(account))
        }
    }
    
    func selectAccount(at index: Int) {
        guard accounts.indices.contains(index), !model.isActive(accounts[index]) else { return }
        
        model.switchTo(accounts[index])
        reload()
    }
    
    func deleteAccount(at index: Int) {
        guard accounts.indices.contains(index) else { return }
        
        model.remove(accounts[index])
        reload()
    }
    
    func addAccount() {
        model.openAddAccount()
    }
    
}
