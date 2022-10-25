//
//  Operation+Extensions.swift
//  
//
//  Created by Serhii Prykhodko on 20.10.2022.
//

import Foundation

extension Operation {
    
    static func makeDependencies(forOperations operations: [Operation]) {
        guard operations.count > 1 else { return }
        
        var i = 0
        var j = 1
        while j < operations.count {
            operations[j].addDependency(operations[i])
            i += 1
            j += 1
        }
    }
    
}
