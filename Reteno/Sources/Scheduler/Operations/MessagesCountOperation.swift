//
//  MessagesCountOperation.swift
//  
//
//  Created by Serhii Prykhodko on 26.10.2022.
//

import Foundation

final class MessagesCountOperation: NetworkOperation {
    
    private var inbox: AppInbox
    
    private let requestService: MobileRequestService
    
    init(requestService: MobileRequestService, inbox: AppInbox) {
        self.requestService = requestService
        self.inbox = inbox
    }
    
    override func main() {
        super.main()
        
        requestService.getInboxMessagesCount { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.inbox.messagesCount = response.unreadCount
                self.finish()
                
            case .failure:
                self.cancel()
            }
        }
    }
    
}
