//
//  InApp.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 30.01.2024.
//

import Foundation

protocol InApp: Codable {
    var id: String { get }
    var model: String { get }
    var personalisation: String? { get }
}

extension InApp {
    var personalisation:String? { nil }
}
