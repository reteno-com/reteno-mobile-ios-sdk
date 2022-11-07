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
        interactionId: String,
        token: String,
        status: InteractionStatus,
        date: Date = Date(),
        completionHandler: @escaping (Result<Void, Error>) -> Void = { _ in }
    ) {
        let request = UpdateInteractionStatusRequest(
            interactionId: interactionId,
            token: token,
            status: status,
            time: date
        )
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result in
            switch result {
            case .success(let success):
                print("request result: \(success)")
                completionHandler(.success(()))
            case .failure(let failure):
                print("request failure: \(failure)")
                completionHandler(.failure(failure))
            }
        }
    }
    
    func registerLinkClick(_ link: String, completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }) {
        let request = RegisterLinkClickRequest(link: link)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
}
