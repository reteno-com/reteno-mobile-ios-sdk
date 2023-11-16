//
//  User.swift
//  Reteno
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

struct User: Codable, Equatable {
    
    let id: String
    let externalUserId: String?
    let userAttributes: UserAttributes?
    let subscriptionKeys: [String]
    let groupNamesInclude: [String]
    let groupNamesExclude: [String]
    let date: Date
    let isAnonymous: Bool
    
    init(
        externalUserId: String? = nil,
        userAttributes: UserAttributes?,
        subscriptionKeys: [String],
        groupNamesInclude: [String],
        groupNamesExclude: [String],
        date: Date = Date(),
        isAnonymous: Bool
    ) {
        self.id = UUID().uuidString
        self.externalUserId = externalUserId
        self.userAttributes = userAttributes
        self.subscriptionKeys = subscriptionKeys
        self.groupNamesInclude = groupNamesInclude
        self.groupNamesExclude = groupNamesExclude
        self.date = date
        self.isAnonymous = isAnonymous
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.externalUserId = try container.decodeIfPresent(String.self, forKey: .externalUserId)
        self.userAttributes = try container.decodeIfPresent(UserAttributes.self, forKey: .userAttributes)
        self.subscriptionKeys = try container.decode([String].self, forKey: .subscriptionKeys)
        self.groupNamesInclude = try container.decode([String].self, forKey: .groupNamesInclude)
        self.groupNamesExclude = try container.decode([String].self, forKey: .groupNamesExclude)
        self.date = try container.decode(Date.self, forKey: .date)
        self.isAnonymous = (try? container.decode(Bool.self, forKey: .isAnonymous)) ?? false
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.externalUserId == rhs.externalUserId && lhs.userAttributes == rhs.userAttributes && lhs.subscriptionKeys == rhs.subscriptionKeys && lhs.groupNamesInclude == rhs.groupNamesInclude && lhs.groupNamesExclude == rhs.groupNamesExclude
    }
    
    var isValid: Bool {
        let lifetime = 40
        return date <= Date() && Date().hours(from: date) < lifetime
    }
}
