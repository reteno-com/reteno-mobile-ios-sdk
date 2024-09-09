//
//  APIRequest.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 12.09.2022.
//

import Foundation

public protocol APIRequest {
    
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
    var parameters: [String: Any]? { get set }
    var headers: [String: String]? { get set }
    
}
