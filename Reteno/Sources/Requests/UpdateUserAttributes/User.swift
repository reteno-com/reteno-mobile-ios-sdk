//
//  User.swift
//  Reteno
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

struct User: Codable {
    
    let id: String
    let externalUserId: String?
    let userAttributes: UserAttributes?
    let subscriptionKeys: [String]
    let groupNamesInclude: [String]
    let groupNamesExclude: [String]
    let date: Date
    
    init(
        externalUserId: String? = nil,
        userAttributes: UserAttributes?,
        subscriptionKeys: [String],
        groupNamesInclude: [String],
        groupNamesExclude: [String],
        date: Date = Date()
    ) {
        self.id = UUID().uuidString
        self.externalUserId = externalUserId
        self.userAttributes = userAttributes
        self.subscriptionKeys = subscriptionKeys
        self.groupNamesInclude = groupNamesInclude
        self.groupNamesExclude = groupNamesExclude
        self.date = date
    }
    
}
