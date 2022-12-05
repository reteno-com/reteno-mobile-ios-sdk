//
//  RecomsResponseHandler.swift
//  
//
//  Created by Anna Sahaidak on 10.11.2022.
//

import Foundation

struct RecomsResponseHandler<Result: RecommendableProduct>: ResponseHandler {
    typealias Value = [Result]
    
    func handleResponse(_ responseData: Data) throws -> [Result] {
        let jsonObject = try JSONSerialization.jsonObject(with: responseData, options: [])
        
        guard let json = jsonObject as? [String: Any], let recoms = json["recoms"] as? [[String: Any]] else {
            throw NetworkError(
                title: "Serialization error",
                detail: "Couldn't parse \(jsonObject.self)",
                invalidParams: nil
            )
        }
        
        return recoms.compactMap { try? Result(json: $0) }
    }
}
