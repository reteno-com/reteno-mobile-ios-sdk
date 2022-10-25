//
//  Optional+Extensions.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 05.10.2022.
//

import Foundation

extension Optional {
    
    var isSome: Bool {
        switch self {
        case .none:
            return false
        case .some:
            return true
        }
    }
    
    var isNone: Bool {
        !isSome
    }
    
}
