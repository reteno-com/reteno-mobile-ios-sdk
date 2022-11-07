//
//  BaseDateFormatter.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 26.10.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

extension DateFormatter {

    static let baseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        return formatter
    }()

}
