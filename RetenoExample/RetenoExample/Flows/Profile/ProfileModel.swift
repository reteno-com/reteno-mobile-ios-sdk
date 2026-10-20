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
    func openAccounts()
    
}

final class ProfileModel {
    
    private var isAnonymous = false
    private var shouldClearMarketId = false
    private var isMarketingPushEnabled = false
    
    private let navigationHandler: ProfileModelNavigationHandler
    
    init(navigationHandler: ProfileModelNavigationHandler) {
        self.navigationHandler = navigationHandler
        
        if let profile = ProfileStorage.profile {
            isAnonymous = profile.isAnonymous
            isMarketingPushEnabled = profile.isMarketingPushEnabled
        }
        
        Reteno.logEvent(
            eventTypeKey: "test_event_type",
            parameters: [
                .init(name: "test", value: "te"),
                .init(name: "equal", value: "teest"),
                .init(name: "start", value: "par")
            ]
        )
    }
    
    // MARK: Multi-account
    
    var isMultiAccountEnabled: Bool {
        MultiAccountStorage.isEnabled
    }
    
    /// When disabled the SDK goes back to the default device id.
    func setMultiAccountEnabled(_ isEnabled: Bool) {
        MultiAccountStorage.isEnabled = isEnabled
        if !isEnabled {
            useDefaultDeviceIdIfNeeded()
        }
    }
    
    /// Suffix of the account the SDK is currently reporting for, `nil` when the default device id is in use.
    func currentAccountSuffix() -> String? {
        Reteno.accountSuffix()
    }
    
    func openAccounts() {
        navigationHandler.openAccounts()
    }
    
    /// Called without arguments `updateMultiAccountUserAttributes` drops the current account
    /// and resets the device id to the default one.
    private func useDefaultDeviceIdIfNeeded() {
        guard Reteno.accountSuffix() != nil else { return }
        
        Reteno.updateMultiAccountUserAttributes()
    }
    
    // MARK: Profile
    
    var storedProfile: StoredProfile? {
        ProfileStorage.profile
    }
    
    func updateShouldClearMarketId(_ shouldClear: Bool) {
        shouldClearMarketId = shouldClear
    }
    
    func updateIsAnonymous(_ isAnonymous: Bool) {
        self.isAnonymous = isAnonymous
    }
    
    func updateIsMarketingPushEnabled(_ isEnabled: Bool) {
        isMarketingPushEnabled = isEnabled
    }
    
    func saveUser(_ user: User) {
        useDefaultDeviceIdIfNeeded()
        
        let marketIdToSend: String? = shouldClearMarketId ? "" : user.marketId
        let fields = [UserCustomField(key: "personal.marketing_push_enabled", value: String(isMarketingPushEnabled))]
        
        if isAnonymous {
            let attributes = AnonymousUserAttributes(
                firstName: user.firstName,
                lastName: user.lastName,
                timeZone: TimeZone.current.identifier,
                marketId: marketIdToSend,
                fields: fields
            )
            Reteno.updateAnonymousUserAttributes(userAttributes: attributes)
        } else {
            Reteno.updateUserAttributes(
                externalUserId: user.id,
                userAttributes: user.userAttributes(marketId: marketIdToSend, fields: fields)
            )
        }
        
        var storedUser = user
        if shouldClearMarketId {
            storedUser.marketId = nil
        }
        ProfileStorage.profile = StoredProfile(
            user: storedUser,
            isAnonymous: isAnonymous,
            isMarketingPushEnabled: isMarketingPushEnabled
        )
        
        navigationHandler.backToMain()
    }
    
    func getUnreadMessagesCount(completion: @escaping (Result<Int, Error>) -> Void) {
        Reteno.inbox().getUnreadMessagesCount(completion: completion)
    }
    
    func getMessages(completion: @escaping (Result<(messages: [AppInboxMessage], totalPages: Int?), Error>) -> Void) {
        Reteno.inbox().downloadMessages(completion: completion)
    }
}
