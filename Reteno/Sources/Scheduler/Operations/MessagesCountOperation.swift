//
//  MessagesCountOperation.swift
//  
//
//  Created by Serhii Prykhodko on 26.10.2022.
//

import Foundation

final class MessagesCountOperation: NetworkOperation, @unchecked Sendable {
    
    private var inbox: AppInbox
    
    private let requestService: MobileRequestService
    
    init(requestService: MobileRequestService, inbox: AppInbox) {
        self.requestService = requestService
        self.inbox = inbox
    }
    
    override func main() {
        super.main()
        
        requestService.getInboxMessagesCount { result in
            switch result {
            case .success(let response):
                self.inbox.messagesCount = response.unreadCount
                
            case .failure:
                self.cancel()
            }
            self.finish()
        }
    }
    
}
