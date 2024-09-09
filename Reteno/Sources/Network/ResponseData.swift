//
//  ResponseData.swift
//  Reteno
//
//  Created by Serhii Navka on 14.08.2024.
//

import Foundation

public struct ResponseData {
    static func headers(from urlResponse: URLResponse?) -> [String: String] {
        guard let httpResponse = urlResponse as? HTTPURLResponse else { return [:] }
        return (httpResponse.allHeaderFields as? [String: String]) ?? [:]
    }
    
    static func statusCode(from urlResponse: URLResponse?) -> Int? {
        guard let httpResponse = urlResponse as? HTTPURLResponse else { return nil }
        
        return httpResponse.statusCode
    }
    
    public let data: Data?
    public let headers: [String: String]
    public let statusCode: Int
}
