//
//  Device.swift
//  Reteno
//
//  Created by Anna Sahaidak on 21.02.2023.
//

import Foundation

struct Device {
    
    let externalUserId: String?
    let phone: String?
    let email: String?
    let isSubscribedOnPush: Bool
    
    init(
        externalUserId: String? = nil,
        phone: String?,
        email: String?,
        isSubscribedOnPush: Bool
    ) {
        self.externalUserId = externalUserId
        self.isSubscribedOnPush = isSubscribedOnPush
        self.email = email
        self.phone = phone
    }

}

extension Device: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.externalUserId == rhs.externalUserId 
        && lhs.isSubscribedOnPush == rhs.isSubscribedOnPush
        && lhs.email == rhs.email
        && lhs.phone == rhs.phone
    }
    
}
