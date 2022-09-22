//
//  ApplicationFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Swinject

final class ApplicationFlowCoordinator {
    
    private let window: UIWindow
    private let container: Container
        
    // MARK: init
    
    init(window: UIWindow) {
        self.window = window
        
        self.container = Container()
        
        MainFlowAssembly().assemble(container: container)
    }
    
    func execute() {
        presentMainFlow()
    }
    
    // MARK: Modules presentation
    
    private func presentMainFlow() {
        let controller = container.resolve(MainViewController.self)!
        setWindowRootViewController(with: controller)
    }
    
    // MARK: Helpers
    
    private func setWindowRootViewController(with viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}
