//
//  Date+Utils.swift
//  Reteno
//
//  Created by Anna Sahaidak on 17.10.2022.
//

import Foundation

extension Date {
    
    static let secondsInHour: Double = 3600
    static let secondsInMinutes: Double = 60
     
    /// Returns an `Int` representing the amount of time in hours between the receiver and the provided date.
    /// If the receiver is earlier than the provided date, the returned value will be negative.
    /// - Parameter date: The provided date for comparison
    /// - returns: The hours between receiver and provided date
    func hours(from date: Date) -> Int {
        Int(timeIntervalSince(date)/Date.secondsInHour)
    }
    
    /// Returns an `Int` representing the amount of time in minutes between the receiver and the provided date.
    /// If the receiver is earlier than the provided date, the returned value will be negative.
    /// - Parameter date: The provided date for comparison
    /// - returns: The hours between receiver and provided date
    func minutes(from date: Date) -> Int {
        Int(timeIntervalSince(date)/Date.secondsInMinutes)
    }
    
    static func dateComponets(units: [Calendar.Component], date: Date) -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents(Set(units), from: date, to: Date())
        
        return components
    }
}
