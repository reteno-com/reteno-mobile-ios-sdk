//
//  ErrorLoger.swift
//
//
//  Created by Oleh Mytsovda on 19.10.2023.
//

import Foundation

final class ErrorLogger {
    static let shared = ErrorLogger()
    
    /// Local storage, based on `UserDefaults`
    private let storage: KeyValueStorage
    
    init() {
        storage = StorageBuilder.build()
    }
    
    func capture(error: Error) {
        storage.addErrorEvent(.init(logLevel: .error, errorMessage: error.localizedDescription))
    }
       
    func captureLog(title: String, count: Int) {
        storage.addErrorEvent(.init(logLevel: .info, errorMessage: "Removed \(title): - \(count)"))
    }
       
    func captureItems(_ items: [Groupable], title: String, tagTitle: String) {
           let groupedItems = items.reduce(into: [String: [Groupable]]()) { result, item in
               if result[item.key].isNone {
                   result[item.key] = []
               }
               result[item.key]?.append(item)
           }
           groupedItems.forEach {
               storage.addErrorEvent(.init(logLevel: .info, errorMessage: "\(title)(\($0.key)) - \($0.value.count)"))
           }
       }
       
    func captureWarningEvent(message: String, tags: [String: String]? = nil) {
        storage.addErrorEvent(.init(logLevel: .warning, data: tags, errorMessage: message))
    }
       
    func captureErrorEvent(message: String, tags: [String: String]? = nil) {
        storage.addErrorEvent(.init(logLevel: .error, data: tags, errorMessage: message))
    }
}
