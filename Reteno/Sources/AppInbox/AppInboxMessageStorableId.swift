//
//  AppInboxMessageStorableId.swift
//  
//
//  Created by Anna Sahaidak on 22.11.2022.
//

import UIKit

struct AppInboxMessageStorableId: Codable {
    
    let id: String
    let date: Date
    /// Identity the message was opened under, `nil` for ids stored by an older SDK version.
    var identity: RequestIdentity? = .current

}

extension AppInboxMessageStorableId: ExpirableData {
    
    static var logTitle: String {
        "Removed inbox opened messages"
    }
    
}
