//
//  DecodableResponseHandler.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

struct DecodableResponseHandler<Result: Decodable>: ResponseHandler {
    typealias Value = Result
    
    func handleResponse(_ responseData: Data) throws -> Result {
        try JSONDecoder().decode(Result.self, from: responseData)
    }
}
