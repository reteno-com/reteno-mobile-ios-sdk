//
//  String+HTML.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 11.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

extension String {
    
    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        
        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
        } catch {
            return nil
        }
    }
    
}
