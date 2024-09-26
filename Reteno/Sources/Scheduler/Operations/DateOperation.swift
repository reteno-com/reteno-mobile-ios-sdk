//
//  DateOperation.swift
//  
//
//  Created by Serhii Prykhodko on 19.10.2022.
//

import Foundation

class DateOperation: NetworkOperation, @unchecked Sendable { 
    
    let date: Date
    
    init(date: Date) {
        self.date = date
    }
    
}
