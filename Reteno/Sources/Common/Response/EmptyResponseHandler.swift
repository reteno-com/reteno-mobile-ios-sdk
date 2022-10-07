//
//  EmptyResponseHandler.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

struct EmptyResponseHandler: ResponseHandler {
    typealias Value = Bool
    
    func handleResponse(_ responseData: Data) throws -> Bool {
        true
    }
}
