//
//  ApplicationFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Swinject

enum UniversalLinkItem: String {
    case inbox = "/app_inbox", profile = "/profile", recom = "/recom"
}

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
    
    // MARK: Deeplinks handling
    
    func handleDeeplink(_ url: URL) {
        guard url.absoluteString.hasPrefix("com.reteno.example-app") else { return }
        
        switch url.absoluteString {
        case "com.reteno.example-app://app_inbox":
            openAppInbox()
            
        case "com.reteno.example-app://recom":
            openRecoms()
            
        case "com.reteno.example-app://profile":
            createProfile()
            
        default:
            break
        }
    }
    
    func handleUniversalLink(_ item: UniversalLinkItem) {
        switch item {
        case .inbox:
            openAppInbox()
            
        case .recom:
            openRecoms()
            
        case .profile:
            createProfile()
        }
    }
    
    // MARK: Modules presentation
    
    private func presentMainFlow() {
        let navigationHandler: MainModelNavigationHandler = self
        let controller = container.resolve(MainViewController.self, argument: navigationHandler)!
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController = navigationController
        setWindowRootViewController(with: navigationController)
    }
    
    // MARK: Helpers
    
    private func setWindowRootViewController(with viewController: UIViewController) {
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
    
}

// MARK: MainModelNavigationHandler

extension ApplicationFlowCoordinator: MainModelNavigationHandler {
    
    func openEcommerce() {
        let flowCoordinator = EcommerceFlowCoordinator(navigationController: navigationController!)
        navigationController?.pushViewController(flowCoordinator.createFlow(), animated: true)
    }
    
    func createProfile() {
        let navigationHandler: ProfileModelNavigationHandler = self
        let controller = container.resolve(ProfileViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openAppInbox() {
        let controller = container.resolve(AppInboxViewController.self)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openRecoms() {
        let flowCoordinator = RecommendationsCoordinator(navigationController: navigationController!)
        navigationController?.pushViewController(flowCoordinator.createFlow(), animated: true)
    }
    
    func openCustomDeviceId() {
        let controller = container.resolve(CustomDeviceIdViewController.self)!
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: ProfileModelNavigationHandler

extension ApplicationFlowCoordinator: ProfileModelNavigationHandler {
    
    func backToMain() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

