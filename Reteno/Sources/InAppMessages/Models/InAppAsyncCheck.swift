//
//  InAppAsyncCheck.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 31.01.2024.
//

import Foundation

struct InAppAsyncChecks: Decodable {
    let checks: [InAppAsyncCheck]
}

struct InAppAsyncCheck: Decodable {
    let segmentId: Int
    let checkResult: Bool
    let error: AsyncRetry?
    
    struct AsyncRetry: Decodable {
        let status: Int
        let retryAfter: RetryAfter?
        
        struct RetryAfter: Decodable {
            let unit: UnitValue
            let amount: Int
        }
    }
    
}
