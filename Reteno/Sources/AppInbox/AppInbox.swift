//
//  AppInbox.swift
//  
//
//  Created by Anna Sahaidak on 25.10.2022.
//

import Foundation

public final class AppInbox {
    
    /// Subscribe on unread messages count changes
    /// set `Value` when you want to start receiving messages count
    /// set `nil` when you want to stop receiving messages count
    public var onUnreadMessagesCountChanged: ((Int) -> Void)? {
        didSet {
            scheduler.messagesCountInbox = onUnreadMessagesCountChanged.isSome ? self : nil
        }
    }
    
    var messagesCount: Int? {
        didSet {
            if messagesCount != oldValue, let count = messagesCount {
                onUnreadMessagesCountChanged?(count)
            }
        }
    }
    
    private let requestService: MobileRequestService
    private let scheduler: EventsSenderScheduler
    
    init(requestService: MobileRequestService, scheduler: EventsSenderScheduler = Reteno.senderScheduler) {
        self.requestService = requestService
        self.scheduler = scheduler
    }
    
    /// Download inbox messages
    ///
    /// - Parameter page: order number of requested page.  If `nil` will be rurned all messages.
    /// - Parameter perPage: messages count per page. If `nil` will be rurned all messages.
    /// - Parameter completion: completion handler `(Result<([AppInboxMessage], Int), Error>) -> Void`
    public func downloadMessages(
        page: Int? = nil,
        pageSize: Int? = nil,
        completion: @escaping (Result<(messages: [AppInboxMessage], totalPages: Int?), Error>) -> Void
    ) {
        requestService.getInboxMessages(page: page, pageSize: pageSize) { result in
            switch result {
            case .success(let response):
                completion(.success((response.messages, response.totalPages)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Change inbox messages status on `OPENED`
    ///
    /// - Parameter messageIds: Array of message identificators, which statuses should be changes
    /// - Parameter completion: Optional completion handler `((Result<Void, Error>) -> Void)?`
    public func markAsOpened(messageIds: [String], completion: ((Result<Void, Error>) -> Void)? = nil) {
        requestService.markInboxMessagesAsOpened(ids: messageIds) { result in
            switch result {
            case .success:
                Reteno.senderScheduler.forceFetchMessagesCount()
                completion?(.success(()))
                
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }

}
