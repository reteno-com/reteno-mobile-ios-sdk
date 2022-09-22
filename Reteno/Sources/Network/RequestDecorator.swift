//
//  RequestDecorator.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 12.09.2022.
//

import Alamofire

struct RequestDecorator {
    
    let decorate: (inout APIRequest) -> Void
    
}
