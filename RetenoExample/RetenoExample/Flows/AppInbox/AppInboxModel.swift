//
//  AppInboxModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 25.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class AppInboxModel {
        
    private var messages: [AppInboxMessage] = []
        
    func messagesCount() -> Int {
        messages.count
    }
    
    func newMessagesCount() -> Int {
        messages.filter { $0.isNew }.count
    }
    
    func message(at index: Int) -> AppInboxMessage {
        messages[index]
    }
    
    func loadMessages(status: AppInboxMessagesStatus?, completion: @escaping (Result<Void, Error>) -> Void) {
        Reteno.inbox().downloadMessages(status: status) { [weak self] result in
            switch result {
            case .success(let response):
                self?.messages = response.messages
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func markMessageAsOpened(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let messageId = messages[index].id
        Reteno.inbox().markAsOpened(messageIds: [messageId]) { result in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makrAllAsOpened(completion: @escaping (Result<Void, Error>) -> Void) {
        Reteno.inbox().markAllAsOpened(completion: completion)
    }
    
}
