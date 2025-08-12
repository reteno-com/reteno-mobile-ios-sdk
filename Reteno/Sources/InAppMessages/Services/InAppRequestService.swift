//
//  InAppRequestService.swift
//  Reteno
//
//  Created by Anna Sahaidak on 25.01.2023.
//

import Foundation

final class InAppRequestService {
    
    private var baseHTMLPath: String {
        if UserDefaults.standard.bool(forKey: "IsCustomInAppURL"),
           let customURL = UserDefaults.standard.string(forKey: "CustomInAppURL") {
            return BaseURL.retenoStatics.rawValue + customURL
        }
        return BaseURL.retenoStatics.rawValue + "in-app/base.latest.html"
    }
    private let requestManager: RequestManager
    
    init(requestManager: RequestManager) {
        self.requestManager = requestManager
    }
    
    func fetchBaseHTML(completionHandler: @escaping (Result<String?, Error>) -> Void = { _ in }) {
        let request = InAppBaseHTMLRequest(path: baseHTMLPath)
        let handler = EmptyResponseHandler()
        
        requestManager.execute(request: request, responseHandler: handler) { result, dataResponse in
            switch result {
            case .success:
                completionHandler(.success(dataResponse?.headers["x-amz-meta-version"]))
                
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
        
        requestManager.download(url: url) { result in
            switch result {
            case .success(let tempFileUrl):
                guard let fileURL = tempFileUrl else {
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
                
            case .failure(let error):
                ErrorLogger.shared.capture(error: error)
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
