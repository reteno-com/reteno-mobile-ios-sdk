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
    private let storage: KeyValueStorage
    
    private var messagesCountResponseHandler: ((Result<Int, Error>) -> Void)?
    private var messagesResponseHandler: ((Result<(messages: [AppInboxMessage], totalPages: Int?), Error>) -> Void)?
    private var messagesRequestParams: InboxMessagesParams?
    
    private var isUserUpdateInProcess: Bool = false
    
    init(
        requestService: MobileRequestService,
        scheduler: EventsSenderScheduler = Reteno.senderScheduler,
        storage: KeyValueStorage
    ) {
        self.requestService = requestService
        self.scheduler = scheduler
        self.storage = storage
        addObservers()
    }
    
    /// Download inbox messages
    ///
    /// - Parameter page: order number of requested page.  If `nil` will be rurned all messages.
    /// - Parameter perPage: messages count per page. If `nil` will be rurned all messages.
    /// - Parameter status: message status to filter. If `nil` messages with all statuses will be returned. 
    /// - Parameter completion: completion handler `(Result<([AppInboxMessage], Int), Error>) -> Void`
    public func downloadMessages(
        page: Int? = nil,
        pageSize: Int? = nil,
        status: AppInboxMessagesStatus? = nil,
        completion: @escaping (Result<(messages: [AppInboxMessage], totalPages: Int?), Error>) -> Void
    ) {
        if isUserUpdateInProcess {
            messagesRequestParams = InboxMessagesParams(page: page, pageSize: pageSize, status: status)
            messagesResponseHandler = completion
        } else {
            requestService.getInboxMessages(page: page, pageSize: pageSize, status: status) { result in
                switch result {
                case .success(let response):
                    completion(.success((response.messages, response.totalPages)))
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Get unread count of App inbox messages
    ///
    /// - Parameter completion: Closure which return unread messages count
    public func getUnreadMessagesCount(
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        if isUserUpdateInProcess {
            messagesCountResponseHandler = completion
        } else {
            requestService.getInboxMessagesCount { result in
                switch result {
                case .success(let item):
                    return completion(.success(item.unreadCount))
                    
                case .failure(let error):
                    return completion(.failure(error))
                }
            }
        }
    }
    
    /// Change inbox messages status on `OPENED`
    ///
    /// - Parameter messageIds: Array of message identificators, which statuses should be changes
    /// - Parameter completion: Optional completion handler `((Result<Void, Error>) -> Void)?`
    public func markAsOpened(messageIds: [String], completion: ((Result<Void, Error>) -> Void)? = nil) {
        let ids = messageIds.map { AppInboxMessageStorableId(id: $0, date: Date()) }
        storage.addInboxOpenedMessagesIds(ids)
        requestService.markInboxMessagesAsOpened(ids: messageIds) { [weak self] result in
            switch result {
            case .success:
                self?.storage.clearInboxOpenedMessagesIds(ids)
                Reteno.senderScheduler.forceFetchMessagesCount()
                completion?(.success(()))
                
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    /// Change all inbox messages status on `OPENED`
    public func markAllAsOpened(completion: ((Result<Void, Error>) -> Void)? = nil) {
        requestService.markInboxMessagesAsOpened { result in
            switch result {
            case .success:
                Reteno.senderScheduler.forceFetchMessagesCount()
                completion?(.success(()))
                
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension AppInbox {
    struct InboxMessagesParams {
        let page: Int?
        let pageSize: Int?
        let status: AppInboxMessagesStatus?
    }
}

private extension AppInbox {
    private func addObservers() {
        NotificationCenter.default.addObserver(forName: Reteno.userUpdateInitiated, object: nil, queue: nil) { [weak self] _ in
            self?.isUserUpdateInProcess = true
        }
        
        NotificationCenter.default.addObserver(forName: Reteno.userUpdateCompleted, object: nil, queue: nil) { [weak self] _ in
            self?.isUserUpdateInProcess = false
            self?.handleUserUpdatedNotification()
            self?.clearData()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.isUserUpdateInProcess = false
            self?.clearData()
        }
    }
    
    private func clearData() {
        messagesResponseHandler = nil
        messagesCountResponseHandler = nil
        messagesRequestParams = nil
    }
    
    private func handleUserUpdatedNotification() {
        if let responseHandler = messagesCountResponseHandler {
            getUnreadMessagesCount(completion: responseHandler)
        }
        
        if let requestParams = messagesRequestParams,
           let responseHandler = messagesResponseHandler {
            downloadMessages(page: requestParams.page,
                             pageSize: requestParams.pageSize,
                             status: requestParams.status,
                             completion: responseHandler)
        }
    }
}
