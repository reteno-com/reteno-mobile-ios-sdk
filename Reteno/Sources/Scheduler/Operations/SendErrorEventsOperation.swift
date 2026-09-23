//
//  SendErrorEventsOperation.swift
//  
//
//  Created by Oleh Mytsovda on 20.10.2023.
//

import Foundation

final class SendErrorEventsOperation: DateOperation, @unchecked Sendable {
    private let requestService: SendingServices
    private let storage: KeyValueStorage
    private let errorEvents: [ErrorEvent]
    
    init(requestService: SendingServices, storage: KeyValueStorage, events: [ErrorEvent]) {
        self.requestService = requestService
        self.storage = storage
        self.errorEvents = events
        
        super.init(date: events.first?.date ?? Date())
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        let storedIds = Set(storage.getErrorEvents().map { $0.id })
        let errorEvents = self.errorEvents.filter { storedIds.contains($0.id) }
        guard errorEvents.isNotEmpty else {
            finish()
            
            return
        }
        
        requestService.sendErrorEvents(errorEvents) { [errorEvents] result in
            switch result {
            case .success:
                self.storage.clearErrorEvents(errorEvents)

            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearErrorEvents(errorEvents)
                        
                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }
}
