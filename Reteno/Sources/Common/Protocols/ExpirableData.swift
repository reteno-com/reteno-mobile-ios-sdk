//
//  ExpirableData.swift
//  
//
//  Created by Anna Sahaidak on 21.10.2022.
//

import Foundation

protocol ExpirableData {
    
    static var logTitle: String { get }
    var isValid: Bool { get }
    var date: Date { get }

}

extension ExpirableData {
    
    var isValid: Bool {
        // Collected data lifetime in hours
        let lifetime = DebugModeHelper.isDebugModeOn() ? 1 : 24
        
        return date <= Date() && Date().hours(from: date) < lifetime
    }
    
}
