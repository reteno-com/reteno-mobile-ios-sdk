//
//  APIRequest.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 12.09.2022.
//

import Alamofire

protocol APIRequest {
    
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding? { get }
    var parameters: Parameters? { get set }
    var headers: HTTPHeaders? { get set }
  
}
