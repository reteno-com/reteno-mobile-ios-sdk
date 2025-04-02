//
//  EventsDateFormatter.swift
//  Reteno
//
//  Created by George Farafonov on 01.04.2025.
//

import Foundation

extension DateFormatter {
    
    static var eventsDateFormatter: ISO8601DateFormatter {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return dateFormatter
    }
    
}
