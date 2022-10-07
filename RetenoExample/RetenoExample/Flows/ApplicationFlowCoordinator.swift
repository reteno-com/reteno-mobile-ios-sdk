//
//  ApplicationFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Swinject

final class ApplicationFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    
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
        let navigationHandler: MainModelNavigationHandler = self
        let controller = container.resolve(MainViewController.self, argument: navigationHandler)!
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController = navigationController
        setWindowRootViewController(with: navigationController)
    }
    
    private func presentMenu() {
        let controller = container.resolve(MenuViewController.self)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Helpers
    
    private func setWindowRootViewController(with viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}

extension ApplicationFlowCoordinator: MainModelNavigationHandler {
    
    func openMenu() {
        presentMenu()
    }
    
}
