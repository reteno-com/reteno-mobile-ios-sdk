//
//  FileStorage.swift
//  Reteno
//
//  Created by George Farafonov on 16.02.2026.
//

import Foundation
import UIKit

internal final class FileStorage {
    static var shared: FileStorage = .init()
    
    private let baseFileName: String = "index.html"
    
    func configure() {
        moveBaseHtmlIfNeeded()
    }
    
    func getBaseHtmlURL() -> URL? {
        let url = FileManager.default.urls(for: .applicationSupportDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(baseFileName)
        if FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }
    
    func saveBaseHtml(_ fileURL: URL, completion: @escaping (Result<Bool, Error>) -> Void) {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let localURL = documentDirectory.appendingPathComponent(baseFileName)
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
            completion(.success(true))
        } catch {
            ErrorLogger.shared.capture(error: error)
            Logger.log("Failed to move file: \(error.localizedDescription)", eventType: .error)
            completion(.failure(error))
        }
    }
    
    func baseHTMLExists() -> Bool {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return false }
        let fileURL = documentsURL.appendingPathComponent("index.html")
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    private func moveBaseHtmlIfNeeded() {
        let sourceUrl = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask)[0].appendingPathComponent(baseFileName)
        
        guard FileManager.default.fileExists(atPath: sourceUrl.path) else { return }
        
        
        let destinationUrl = FileManager.default.urls(for: .applicationSupportDirectory,
                                                      in: .userDomainMask)[0].appendingPathComponent(baseFileName)
        do {
            try FileManager.default.moveItem(at: sourceUrl, to: destinationUrl)
            Logger.log("Reteno: Base HTML Moved to application support", eventType: .info)
        } catch {
            Logger.log("Reteno: Failed to move Base HTML to application support: \(error.localizedDescription)", eventType: .error)
        }
    }
}
