//
//  Dictionary+getHeaderValue.swift
//  Reteno
//
//  Created by Serhii Navka on 14.08.2024.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    func getHeaderValue(for key: Key) -> Value? {
        first { dictElement in
            dictElement.key.lowercased() == key.lowercased()
        }?.value
    }
}
