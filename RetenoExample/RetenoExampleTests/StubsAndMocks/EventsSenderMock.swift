//
//  EventsSenderMock.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 03.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class EventsSenderMock: EventsSender {
    
    private(set) var eventTypeKey: String = ""
    private(set) var params: [Event.Parameter] = []
    
    func sendScreenViewEvent(
        eventTypeKey: String,
        date: Date,
        params: [Event.Parameter],
        completionHandler: @escaping (Result<Void, Error>) -> Void
    ) {
        self.eventTypeKey = eventTypeKey
        self.params = params
    }
    
}
