//
//  Log.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 20.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import Foundation

struct Logger {
    
    enum EventType: String {
        case error = "‼️"
        case info = "ℹ️"
        case debug = "💬"
        case verbose = "🔬"
        case warning = "⚠️"
        case critical = "🔥"
    }
    
    private static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }
    
    // MARK: Logging
    
    static func log( _ object: Any, eventType: EventType) {
        #if DEBUG
        print("\(eventType.rawValue) \(dateFormatter.string(from: Date())) \(eventType.rawValue) [Reteno] - \(object)")
        #endif
    }
}
