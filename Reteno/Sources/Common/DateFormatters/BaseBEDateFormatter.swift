//
//  BaseBEDateFormatter.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 13.09.2022.
//

import Foundation

extension DateFormatter {

    static let baseBEDateFormatter = ISO8601DateFormatter()
    
    static var scheduleDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        return dateFormatter
    }
    
}
