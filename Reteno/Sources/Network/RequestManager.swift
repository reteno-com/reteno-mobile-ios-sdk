//
//  RequestManager.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 12.09.2022.
//

import Foundation

final class RequestManager {
    
    private let decorators: [RequestDecorator]
    private let baseURLComponent: String
    private let session: URLSession
    
    init(
        configuration: URLSessionConfiguration = .default,
        baseURLComponent: String = BaseURL.default.rawValue,
        decorators: [RequestDecorator] = []
    ) {
        self.decorators = decorators
        self.baseURLComponent = baseURLComponent
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func execute<Handler: ResponseHandler>(
        request: APIRequest,
        responseHandler: Handler,
        completionHandler: @escaping (Result<Handler.Value, Error>) -> Void
    ) {
        _execute(
            request: request,
            responseHandler: responseHandler,
            completionHandler: { result, responseData in
                completionHandler(result)
            })
    }
    
    func execute<Handler: ResponseHandler>(
        request: APIRequest,
        responseHandler: Handler,
        completionHandler: @escaping (Result<Handler.Value, Error>, ResponseData?) -> Void
    ) {
        _execute(
            request: request,
            responseHandler: responseHandler,
            completionHandler: completionHandler
        )
    }
    
    func download(url: URL, completionHandler: @escaping (Result<URL?, Error>) -> Void) {
        let urlRequest = URLRequest(url: url)
        session.downloadTask(
            with: urlRequest,
            completionHandler: { tempFileUrl, _, error in
                if let error = error {
                    completionHandler(.failure(error))
                }
                completionHandler(.success(tempFileUrl))
            }
        ).resume()
    }
    
    private func _execute<Handler: ResponseHandler>(
        request: APIRequest,
        responseHandler: Handler,
        completionHandler: @escaping (Result<Handler.Value, Error>, ResponseData?) -> Void
    ) {
        var request = request
        for decorator in decorators {
            decorator.decorate(&request)
        }
        
        if DebugModeHelper.isDebugModeOn() {
            Logger.log(request, eventType: .info)
        }
        
        var urlRequest: URLRequest!
        do {
            urlRequest = try toUrlRequest(request)
        } catch let error {
            completionHandler(.failure(error), nil)
            return
        }
        
        session.dataTask(with: urlRequest) { [weak self] data, urlResponse, error in
            guard let self = self else { return }
            
            let statusCode = ResponseData.statusCode(from: urlResponse) ?? -1
            let responseData = ResponseData(
                data: data,
                headers: ResponseData.headers(from: urlResponse),
                statusCode: statusCode
            )
            
            if let urlSessionError = error {
                let wrappedError = ContainerError(statusCode: statusCode, error: urlSessionError)
                completionHandler(.failure(wrappedError), responseData)
                return
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                completionHandler(.failure(APIClientError.wrongResponse), responseData)
                return
            }
            
            do {
                if let parsedError = try self.processError(using: httpResponse, data: data) {
                    completionHandler(.failure(parsedError), responseData)
                } else {
                    let resultValue = try responseHandler.handleResponse(data ?? Data())
                    completionHandler(.success(resultValue), responseData)
                }
            } catch {
                let wrappedError = ContainerError(statusCode: statusCode, error: error)
                completionHandler(.failure(wrappedError), responseData)
            }
        }.resume()
    }
    
    private func toUrlRequest(_ request: APIRequest) throws -> URLRequest {
        let url = try buildURL(host: baseURLComponent, path: request.path)
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = request.headers
        urlRequest.httpMethod = request.method.rawValue
        urlRequest = try request.encoding.encode(urlRequest, with: request.parameters)
        
        return urlRequest
    }
    
    private func buildURL(
        host: String,
        path: String
    ) throws -> URL {
        guard let url = URL(string: host + path) else {
            throw APIClientError.incorrectURL
        }
        return url
    }
    
    private func processError(using httpResponse: HTTPURLResponse, data: Data?) throws -> Error? {
        guard let data = data else { return nil }
        
        switch httpResponse.statusCode {
        case 200..<299:
            return nil
            
        default:
            let serverError: Error? = try parseError(data: data, statusCode: httpResponse.statusCode)
            
            return serverError
        }
    }
    
    private func parseError(data: Data?, statusCode: Int) throws -> NetworkError? {
        let errorHandler = DecodableResponseHandler<NetworkError>()
        var networkError = try errorHandler.handleResponse(data ?? Data())
        networkError.statusCode = statusCode
        
        if DebugModeHelper.isDebugModeOn() {
            Logger.log(networkError, eventType: .error)
        }
        
        return networkError
    }
}
