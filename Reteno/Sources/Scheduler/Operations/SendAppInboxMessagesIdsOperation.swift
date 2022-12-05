//
//  SendAppInboxMessagesIdsOperation.swift
//  
//
//  Created by Anna Sahaidak on 22.11.2022.
//

import Foundation
import Alamofire

final class SendAppInboxMessagesIdsOperation: DateOperation {
    
    private let requestService: MobileRequestService
    private let storage: KeyValueStorage
    private let ids: [AppInboxMessageStorableId]
    
    init(requestService: MobileRequestService, storage: KeyValueStorage, ids: [AppInboxMessageStorableId]) {
        self.requestService = requestService
        self.storage = storage
        self.ids = ids
        
        super.init(date: ids.first?.date ?? Date())
    }
    
    override func main() {
        super.main()
        
        guard !isCancelled else {
            finish()
            
            return
        }
        
        requestService.markInboxMessagesAsOpened(ids: ids.map { $0.id }) { [weak self, ids] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.storage.clearInboxOpenedMessagesIds(ids)

            case .failure(let error):
                if let responseCode = (error as? NetworkError)?.statusCode ?? (error as? AFError)?.responseCode {
                    switch responseCode {
                    case 400...499:
                        self.storage.clearInboxOpenedMessagesIds(ids)

                    default:
                        break
                    }
                }
            }
            self.finish()
        }
    }

}
