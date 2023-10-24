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
        
        if DebugModeHelper.isDebugModeOn() {
            Logger.log(request, eventType: .info)
        }
        
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
                    ErrorLogger.shared.capture(error: error)
                    if DebugModeHelper.isDebugModeOn() {
                        Logger.log(error, eventType: .error)
                    }
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
                if DebugModeHelper.isDebugModeOn() {
                    Logger.log(networkError ?? error, eventType: .error)
                }
                completionHandler(.failure(networkError ?? error))
            }
        }
    }
    
    func execute<Handler: ResponseHandler>(
        request: APIRequest,
        responseHandler: Handler,
        completionHandler: @escaping (Result<Handler.Value, Error>, HTTPHeaders?) -> Void
    ) {
        var request = request
        for decorator in decorators {
            decorator.decorate(&request)
        }
        
        if DebugModeHelper.isDebugModeOn() {
            Logger.log(request, eventType: .debug)
        }
        
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
                    completionHandler(.success(resultValue), response.response?.headers)
                } catch {
                    ErrorLogger.shared.capture(error: error)
                    completionHandler(.failure(error), response.response?.headers)
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
                completionHandler(.failure(networkError ?? error), response.response?.headers)
            }
        }
    }
    
}

