//
//  AddAccountModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation
import Reteno

protocol AddAccountModelNavigationHandler {
    
    func backToAccounts()
    
}

final class AddAccountModel {
    
    private let navigationHandler: AddAccountModelNavigationHandler
    
    init(navigationHandler: AddAccountModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    /// Identifies the SDK as the new account (device id `<baseDeviceId>:<suffix>`) and keeps it in the local list.
    func save(_ user: User, accountSuffix: String?) {
        Reteno.updateMultiAccountUserAttributes(
            externalUserId: user.id,
            userAttributes: user.userAttributes(marketId: user.marketId),
            accountSuffix: accountSuffix
        )
        MultiAccountStorage.upsert(SavedAccount(
            externalUserId: user.id,
            accountSuffix: accountSuffix,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email
        ))
        navigationHandler.backToAccounts()
    }
    
}
