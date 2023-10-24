//
//  SendErrorEventsOperation.swift
//  
//
//  Created by Oleh Mytsovda on 20.10.2023.
//

import Foundation
import Alamofire

final class SendErrorEventsOperation: DateOperation {
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
        
        requestService.sendErrorEvents(errorEvents) { [weak self, errorEvents] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.storage.clearErrorEvents(errorEvents)

            case .failure(let error):
                if let responseCode = (error as? NetworkError)?.statusCode ?? (error as? AFError)?.responseCode {
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
