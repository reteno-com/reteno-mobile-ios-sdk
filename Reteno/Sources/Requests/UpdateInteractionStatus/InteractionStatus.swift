//
//  InteractionStatus.swift
//  Reteno
//
//  Created by Serhii Prykhodko on 13.09.2022.
//

import Foundation

public enum InteractionStatus: String, Codable {
    
    case delivered = "DELIVERED"
    case opened = "OPENED"
    case clicked = "CLICKED"
    
}   
