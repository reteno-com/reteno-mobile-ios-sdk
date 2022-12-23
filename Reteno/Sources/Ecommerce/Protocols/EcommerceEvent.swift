//
//  EcommerceEvent.swift
//  
//
//  Created by Anna Sahaidak on 28.11.2022.
//

import Foundation

protocol EcommerceEvent {
    
    var eventTypeKey: String { get }
    var date: Date { get }
    var parameters: [Event.Parameter] { get }
    
    func convertToEvent() -> Event
    
}

extension EcommerceEvent {
    
    func convertToEvent() -> Event {
        Event(eventTypeKey: eventTypeKey, date: date, parameters: parameters)
    }
    
}
