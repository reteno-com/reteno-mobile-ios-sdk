//
//  SendingServices.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Alamofire
import Foundation

final class SendingServices {
    
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    
    func updateInteractionStatus(
        status: NotificationStatus,
        token: String,
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let request = UpdateInteractionStatusRequest(status: status, token: token)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    func registerLinkClick(_ link: String, completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }) {
        let request = RegisterLinkClickRequest(link: link)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
    // MARK: ErrorEventsSender
    
    func sendErrorEvents(_ errorEvents: [ErrorEvent], completionHandler: @escaping (Result<Void, Error>) -> Void = { _ in }) {
        let request = ErrorEventRequest(events: errorEvents)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            switch result {
            case .success:
                completionHandler(.success(()))
                
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
}
