//
//  RequestManager.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 12.09.2022.
//

import Alamofire
import Foundation

final class RequestManager {
    
    private let decorators: [RequestDecorator]
    private let baseURLComponent: String
    
    init(decorators: [RequestDecorator] = [], baseURLComponent: String = BaseURL.default.rawValue) {
        self.decorators = decorators
        self.baseURLComponent = baseURLComponent
    }
    
    func execute<Handler: ResponseHandler>(
        request: APIRequest,
        responseHandler: Handler,
        completionHandler: @escaping (Result<Handler.Value, Error>) -> Void
    ) {
        var request = request
        for decorator in decorators {
            decorator.decorate(&request)
        }
        
        print(request)
        
        AF.request(
            baseURLComponent + request.path,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encoding ?? JSONEncoding.default,
            headers: request.headers
        )
        .validate()
        .responseData { response in
            let dataHandling: (Data) -> Void = { data in
                do {
                    let resultValue = try responseHandler.handleResponse(data)
                    completionHandler(.success(resultValue))
                } catch {
                    SentryHelper.capture(error: error)
                    completionHandler(.failure(error))
                }
            }
            
            if response.response?.statusCode == 200 {
                dataHandling(response.data ?? Data())
                
                return
            }
            
            switch response.result {
            case let .success(data):
                dataHandling(data)
                
            case let .failure(error):
                let errorHandler = DecodableResponseHandler<NetworkError>()
                var networkError = try? errorHandler.handleResponse(response.data ?? Data())
                networkError?.statusCode = response.error?.asAFError?.responseCode
                completionHandler(.failure(networkError ?? error))
            }
        }
    }
    
}

