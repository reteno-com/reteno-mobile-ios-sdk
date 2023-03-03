//
//  Device.swift
//  Reteno
//
//  Created by Anna Sahaidak on 21.02.2023.
//

import Foundation

struct Device {
    
    let externalUserId: String?
    let isSubscribedOnPush: Bool
    
    init(externalUserId: String? = nil, isSubscribedOnPush: Bool) {
        self.externalUserId = externalUserId
        self.isSubscribedOnPush = isSubscribedOnPush
    }

}

extension Device: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.externalUserId == rhs.externalUserId && lhs.isSubscribedOnPush == rhs.isSubscribedOnPush
    }
    
}
