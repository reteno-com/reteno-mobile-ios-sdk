//
//  EventsSender.swift
//  Reteno
//
//  Created by Anna Sahaidak on 03.10.2022.
//

import Foundation

protocol EventsSender {
    
    func sendEvents(_ events: [Event], completionHandler: @escaping (Result<Void, Error>) -> Void)
    
}
