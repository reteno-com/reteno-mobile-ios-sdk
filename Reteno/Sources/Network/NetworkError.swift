//
//  NetworkError.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 11.10.2022.
//

import Foundation

struct NetworkError {
    
    var statusCode: Int?
    let title: String
    let detail: String?
    let invalidParams: [ValidationError]?
    
    enum CodingKeys: String, CodingKey {
        
        case title
        case detail
        case invalidParams = "invalid-params"
        
    }
    
}

// MARK: ValidationError

extension NetworkError {
    
    struct ValidationError {
        
        let name: String
        let reason: String
        
    }
    
}

// MARK: Decodable

extension NetworkError.ValidationError: Decodable {}

extension NetworkError: Decodable {}

// MARK: Error

extension NetworkError: Error, LocalizedError {
    
    var errorDescription: String? {
        var composedString: String = title
        
        if let detail = detail {
            composedString += ": \(detail)"
        }
        if let invalidParams = invalidParams {
            for param in invalidParams {
                composedString += "\n\(param.name): \(param.reason)"
            }
        }
        
        return composedString
    }
    
}
