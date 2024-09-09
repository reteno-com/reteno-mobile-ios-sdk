//
//  DictionaryResponseHandler.swift
//  Reteno
//
//  Created by Serhii Navka on 18.08.2024.
//

import Foundation

struct DictionaryResponseHandler: ResponseHandler {
    
    typealias Value = [String: Any]
    
    func handleResponse(_ responseData: Data) throws -> [String: Any] {
        guard let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
            throw NetworkError(
                title: "Serialization error",
                detail: "Couldn't parse \(String(decoding: responseData, as: UTF8.self))",
                invalidParams: nil
            )
        }
        return jsonObject
    }
}
