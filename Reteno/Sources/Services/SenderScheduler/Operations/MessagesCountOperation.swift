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
        
        requestService.getInboxMessagesCount { [unowned self] result in
            switch result {
            case .success(let response):
                self.inbox.messagesCount = response.unreadCount
                self.finish()
                
            case .failure(let failure):
                print("MessagesCountOperation finish with error: \(failure.localizedDescription)")
                self.cancel()
            }
        }
    }
    
}
