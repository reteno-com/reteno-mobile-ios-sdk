//
//  SendEventsOperation.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation

final class SendEventsOperation: DateOperation {
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let events: [Event]
    
    init(requestService: MobileRequestService, storage: KeyValueStorage, events: [Event]) {
        self.requestService = requestService
        self.storage = storage
        self.events = events
        
        super.init(date: events.first?.date ?? Date())
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.sendEvents(events) { [unowned self, events] result in
            guard !self.isCancelled else {
                self.finish()
                
                return
            }
            
            if case .success = result {
                self.storage.clearEvents(events)
            }
            self.finish()
        }
    }
    
}
