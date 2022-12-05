//
//  SendEventsOperation.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation
import Alamofire

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
        
        requestService.sendEvents(events) { [weak self, events] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.storage.clearEvents(events)
                
            case .failure(let error):
                if let responseCode = (error as? NetworkError)?.statusCode ?? (error as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearEvents(events)
                        
                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }
    
}
