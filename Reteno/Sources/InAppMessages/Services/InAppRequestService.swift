//
//  InAppRequestService.swift
//  Reteno
//
//  Created by Anna Sahaidak on 25.01.2023.
//

import Foundation
import Alamofire

final class InAppRequestService {
    
    private let baseHTMLPath = BaseURL.retenoStatics.rawValue + "in-app/base.latest.html"
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    
    func fetchBaseHTML(completionHandler: @escaping (Result<String?, Error>) -> Void = { _ in }) {
        let request = InAppBaseHTMLRequest(path: baseHTMLPath)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result, headers in
            switch result {
            case .success:
                completionHandler(.success(headers?.value(for: "x-amz-meta-version")))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func downloadBaseHTML(completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }) {
        guard let url = URL(string: baseHTMLPath) else {
            completionHandler(.success(false))
            return
        }
        
        AF.download(url).response { response in
            guard let fileURL = response.fileURL else {
                completionHandler(.success(false))
                return
            }
            
            // Move the downloaded file to Documents folder
            let fileManager = FileManager.default
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let localURL = documentDirectory.appendingPathComponent("index.html")
            do {
                let path: String = {
                    if #available(iOS 16.0, *) {
                        return localURL.path()
                    } else {
                        return localURL.path
                    }
                }()
                if fileManager.fileExists(atPath: path) {
                    try fileManager.removeItem(at: localURL)
                }
                try fileManager.moveItem(at: fileURL, to: localURL)
                completionHandler(.success(true))
            } catch {
                ErrorLogger.shared.capture(error: error)
                Logger.log("Failed to move file: \(error.localizedDescription)", eventType: .error)
                completionHandler(.failure(error))
            }
        }
    }
    
    func sendScriptEvent(
        messageId: String,
        data: [String: Any],
        completionHandler: @escaping (Result<Bool, Error>) -> Void = { _ in }
    ) {
        let request = InAppScriptEventRequest(messageId: messageId, data: data)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler, completionHandler: completionHandler)
    }
    
}
