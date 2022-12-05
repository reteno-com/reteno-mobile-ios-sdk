//
//  SendRecomEventsOperation.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import Foundation
import Alamofire

final class SendRecomEventsOperation: DateOperation {
    
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
        
        requestService.sendRecomEvents(events) { [weak self, events] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.storage.clearRecomEvents(events)

            case .failure(let error):
                if let responseCode = (error as? NetworkError)?.statusCode ?? (error as? AFError)?.responseCode {
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
