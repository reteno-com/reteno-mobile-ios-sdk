//
//  PauseBehavior.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 12.04.2024.
//

import Foundation

public enum PauseBehaviour: String {
    /// Skipped all InAppMessages until pause enabled.
    case skipInApps
    /// Skipped all InAppMessages until pause is enabled and show the first one (if it existed) when pause is disabled.
    case postponeInApps
}

extension PauseBehaviour: Codable {}
