//
//  AccountsListModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

protocol AccountsListModelNavigationHandler {
    
    func openAddAccount()
    
}

final class AccountsListModel {
    
    private let navigationHandler: AccountsListModelNavigationHandler
    
    init(navigationHandler: AccountsListModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func accounts() -> [SavedAccount] {
        MultiAccountStorage.accounts()
    }
    
    func isActive(_ account: SavedAccount) -> Bool {
        account.resolvedSuffix == Reteno.accountSuffix()
    }
    
    /// Re-identifies the SDK as `account`: the device id becomes `<baseDeviceId>:<suffix>` and the
    /// previous account's identity is dropped, so accounts never share data.
    func switchTo(_ account: SavedAccount) {
        Reteno.updateMultiAccountUserAttributes(
            externalUserId: account.externalUserId,
            accountSuffix: account.accountSuffix
        )
    }
    
    /// Removing the active account sends the SDK back to the default device id.
    func remove(_ account: SavedAccount) {
        if isActive(account) {
            Reteno.updateMultiAccountUserAttributes()
        }
        MultiAccountStorage.remove(account)
    }
    
    func openAddAccount() {
        navigationHandler.openAddAccount()
    }
    
}
