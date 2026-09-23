//
//  EventsSenderMock.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 03.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class EventsSenderMock: EventsSender {
    
    private(set) var events: [Event] = []
    
    func sendEvents(_ events: [Event], completionHandler: @escaping (Result<Void, Error>) -> Void) {
        self.events = events
    }
    
    func cancelExecution() {}
    
}

final class EventsRequestsRecorder {
    
    private let lock = NSLock()
    private let trackedEventTypeKeys: Set<String>
    private var recordedBatches: [[String]] = []
    
    init(trackedEventTypeKeys: [String]) {
        self.trackedEventTypeKeys = Set(trackedEventTypeKeys)
    }
    
    var batches: [[String]] {
        lock.lock()
        defer { lock.unlock() }
        
        return recordedBatches
    }
    
    var sentEventTypeKeys: [String] {
        batches.flatMap { $0 }
    }
    
    func record(_ request: URLRequest) {
        let body = (request as NSURLRequest).ohhttpStubs_HTTPBody()
        let json = body.flatMap { try? JSONSerialization.jsonObject(with: $0) } as? [String: Any]
        let events = json?["events"] as? [[String: Any]] ?? []
        let keys = events
            .compactMap { $0["eventTypeKey"] as? String }
            .filter { trackedEventTypeKeys.contains($0) }
        guard keys.isNotEmpty else { return }
        
        lock.lock()
        recordedBatches.append(keys)
        lock.unlock()
    }
    
    func stubEventsRequest(statusCode: Int32 = 200, responseTime: TimeInterval = 0) {
        stub(condition: pathEndsWith("v1/events")) { [weak self] request in
            self?.record(request)
            
            return HTTPStubsResponse(data: "OK".data(using: .utf8)!, statusCode: statusCode, headers: nil)
                .responseTime(responseTime)
        }
    }
    
}
