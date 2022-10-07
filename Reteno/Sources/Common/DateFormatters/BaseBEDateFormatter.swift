//
//  BaseBEDateFormatter.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 13.09.2022.
//

import Foundation

extension DateFormatter {

    static let baseBEDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'hh:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        return formatter
    }()

}
