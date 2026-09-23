//
//  SendRecomEventsOperation.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Foundation

final class SendRecomEventsOperation: DateOperation, @unchecked Sendable {
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let events: [RecomEvents]
    
    init(requestService: MobileRequestService, storage: KeyValueStorage, events: [RecomEvents]) {
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
        
        let storedIds = Set(storage.getRecomEvents().map { $0.id })
        let events = self.events.filter { storedIds.contains($0.id) }
        guard events.isNotEmpty else {
            finish()
            
            return
        }
        
        requestService.sendRecomEvents(events) { [events] result in
            switch result {
            case .success:
                self.storage.clearRecomEvents(events)

            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearRecomEvents(events)

                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }

}
