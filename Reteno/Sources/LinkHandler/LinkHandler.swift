//
//  LinkHandler.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 01.04.2024.
//

import Foundation

public struct LinkHandler {
    public let url: URL?
    public let customData: [String: Any]?
    public let source: LinkSource
}

public enum LinkSource {
    case pushNotification, inAppMessage
}
