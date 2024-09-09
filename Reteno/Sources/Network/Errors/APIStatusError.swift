//
//  APIStatusError.swift
//  Reteno
//
//  Created by Serhii Navka on 14.08.2024.
//

import Foundation

protocol APIStatusError: Error {
    var statusCode: Int? { get }
}
