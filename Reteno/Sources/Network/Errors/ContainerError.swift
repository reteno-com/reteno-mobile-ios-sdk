//
//  ContainerError.swift
//  Reteno
//
//  Created by Serhii Navka on 14.08.2024.
//

import Foundation

struct ContainerError: APIStatusError, LocalizedError {
    let statusCode: Int?
    let error: Error
    
    var errorDescription: String? { error.localizedDescription }
}
