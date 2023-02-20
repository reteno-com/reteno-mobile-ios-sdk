//
//  StorableLink.swift
//  Reteno
//
//  Created by Anna Sahaidak on 08.02.2023.
//

import Foundation

struct StorableLink: Codable {
    
    let value: String
    let date: Date

}

extension StorableLink: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
    
}

extension StorableLink: ExpirableData {
    
    static var logTitle: String { "Removed wrapped links" }
    
}

extension StorableLink: Groupable {
    
    static var keyTitle: String { "link" }
    var key: String { value }
    
}
