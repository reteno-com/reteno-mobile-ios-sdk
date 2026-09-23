//
//  SendAppInboxMessagesIdsOperation.swift
//  
//
//  Created by Anna Sahaidak on 22.11.2022.
//

import Foundation

final class SendAppInboxMessagesIdsOperation: DateOperation, @unchecked Sendable {
    
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
        
        let storedIds = Set(storage.getInboxOpenedMessagesIds().map { $0.id })
        let ids = self.ids.filter { storedIds.contains($0.id) }
        guard ids.isNotEmpty else {
            finish()
            
            return
        }
        
        requestService.markInboxMessagesAsOpened(ids: ids.map { $0.id }) { [ids] result in
            switch result {
            case .success:
                self.storage.clearInboxOpenedMessagesIds(ids)

            case .failure(let error):
                if let responseCode = (error as? APIStatusError)?.statusCode {
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
