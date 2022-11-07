//
//  AppInboxViewModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 25.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class AppInboxViewModel {
        
    private let model: AppInboxModel
    
    init(model: AppInboxModel) {
        self.model = model
    }
    
    func messagesCount() -> Int {
        model.messagesCount()
    }
    
    func message(at index: Int) -> AppInboxMessage {
        model.message(at: index)
    }
    
    func loadMessages(completion: @escaping (Result<Void, Error>) -> Void) {
        model.loadMessages(completion: completion)
    }
    
    func markMessageAsOpened(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        model.markMessageAsOpened(at: index, completion: completion)
    }
    
}
