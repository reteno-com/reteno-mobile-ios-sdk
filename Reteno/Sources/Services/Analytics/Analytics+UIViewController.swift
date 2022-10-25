//
//  Analytics+UIViewController.swift
//  Reteno
//
//  Created by Anna Sahaidak on 03.10.2022.
//

import UIKit

extension UIViewController {
    
    @objc func viewDidAppearOverride(_ animated: Bool) {
        // In case we need to override this method
        self.viewDidAppearOverride(animated)
        
        Reteno.logEvent(
            eventTypeKey: ScreenViewEvent,
            parameters: [Event.Parameter(name: ScreenClass, value: String(describing: type(of: self)))]
        )
    }

    static func swizzleViewDidAppear() {
        // Make sure this isn't a subclass of UIViewController, So that it applies to all UIViewController childs.
        guard self == UIViewController.self else { return }
        
        let originalSelector = #selector(UIViewController.viewDidAppear(_:))
        let swizzledSelector = #selector(UIViewController.viewDidAppearOverride(_:))
        guard
            let originalMethod = class_getInstanceMethod(self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    
}
