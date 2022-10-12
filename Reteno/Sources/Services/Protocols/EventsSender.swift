//
//  EventsSender.swift
//  Reteno
//
//  Created by Anna Sahaidak on 03.10.2022.
//

import Foundation

protocol EventsSender {
    
    func sendScreenViewEvent(
        eventTypeKey: String,
        date: Date,
        params: [Event.Parameter],
        completionHandler: @escaping (Result<Void, Error>) -> Void
    )
    
}
