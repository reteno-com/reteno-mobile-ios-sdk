//
//  JSONConverterHelper.swift
//  
//
//  Created by Anna Sahaidak on 28.11.2022.
//

import UIKit

public struct JSONConverterHelper {
    
    public static func convertJSONToString(_ json: Any) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            return String(data: data, encoding: .utf8)
        } catch {
            ErrorLogger.shared.capture(error: error)
            return nil
        }
    }

}
