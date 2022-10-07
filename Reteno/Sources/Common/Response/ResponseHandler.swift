//
//  ResponseHandler.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 14.09.2022.
//

import Foundation

public protocol ResponseHandler {
    
    associatedtype Value
    
    func handleResponse(_ responseData: Data) throws -> Value
    
}
