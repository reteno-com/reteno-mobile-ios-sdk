//
//  Date+Utils.swift
//  Reteno
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

extension Date {
    
    static let secondsInHour: Double = 3600
    
    /// Returns an `Int` representing the amount of time in hours between the receiver and the provided date.
    /// If the receiver is earlier than the provided date, the returned value will be negative.
    /// - Parameter date: The provided date for comparison
    /// - returns: The hours between receiver and provided date
    func hours(from date: Date) -> Int {
        Int(timeIntervalSince(date)/Date.secondsInHour)
    }
    
}
