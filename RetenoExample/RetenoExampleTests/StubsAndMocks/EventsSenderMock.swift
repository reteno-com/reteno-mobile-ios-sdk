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
    
    private(set) var events: [Event] = []
    
    func sendEvents(_ events: [Event], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.events = events
    }
    
    func cancelExecution() {}
    
}
