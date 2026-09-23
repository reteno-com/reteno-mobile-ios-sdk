//
//  EventsDateFormatter.swift
//  Reteno
//
//  Created by George Farafonov on 01.04.2025.
//

import Foundation

extension DateFormatter {
    
    /// Built once - `Event.toJSON()` is called for every event of every batch, and creating a
    /// formatter per call is one of the more expensive things the sending path does.
    /// `ISO8601DateFormatter` is thread safe for formatting once configured.
    static let eventsDateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return dateFormatter
    }()
    
}
