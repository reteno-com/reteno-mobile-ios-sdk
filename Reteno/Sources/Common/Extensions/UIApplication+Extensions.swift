//
//  UIApplication+Extensions.swift
//  
//
//  Created by Anna Sahaidak on 20.01.2023.
//

import UIKit

extension UIApplication {
    
    var isActive: Bool {
        guard isUsingUIScene else { return applicationState == .active }
        
        if #available(iOS 13.0, *) {
            let keyWindow = connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
            return keyWindow?.windowScene?.session.scene?.activationState == .foregroundActive
        } else {
            return applicationState == .active
        }
    }
    
    var isUsingUIScene: Bool {
        if #available(iOS 13.0, *) {
            return Bundle.main.object(forInfoDictionaryKey: "UIApplicationSceneManifest").isSome
        } else {
            return false
        }
    }
    
}
