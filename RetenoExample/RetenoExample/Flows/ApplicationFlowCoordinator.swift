//
//  ApplicationFlowCoordinator.swift
//
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Swinject

final class ApplicationFlowCoordinator {
    
    private weak var navigationController: UINavigationController?
    
    private weak var recomsViewComtroller: RecomsViewController?
    
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
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(EcommerceViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
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
        let navigationHandler: RecomsModelNavigationHandler = self
        let controller = container.resolve(RecomsViewController.self, argument: navigationHandler)!
        recomsViewComtroller = controller
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: EcommerceModelNavigationHandler

extension ApplicationFlowCoordinator: EcommerceModelNavigationHandler {
    
    func openProductViewed() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(ProductViewedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openProductCategoryViewed() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(ProductCategoryViewedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openProductAddedToWishlist() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(ProductAddedToWishlistViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openCartUpdated() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(CartUpdatedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openOrderCreated() {
        let navigationHandler: OrderCreatedModelNavigationHandler = self
        let controller = container.resolve(
            OrderCreatedViewController.self,
            arguments: navigationHandler, OrderCreatedModel.State.create
        )!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openOrderUpdated() {
        let navigationHandler: OrderCreatedModelNavigationHandler = self
        let controller = container.resolve(
            OrderCreatedViewController.self,
            arguments: navigationHandler, OrderCreatedModel.State.update
        )!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openOrderDelivered() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(OrderDeliveredViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openOrderCancelled() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(OrderCancelledViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func openSearchRequest() {
        let navigationHandler: EcommerceViewsNavigationHandler = self
        let controller = container.resolve(SearchRequestViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: EcommerceViewsNavigationHandler

extension ApplicationFlowCoordinator: EcommerceViewsNavigationHandler {
    
    func backToEcommerce() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: ProfileModelNavigationHandler

extension ApplicationFlowCoordinator: ProfileModelNavigationHandler {
    
    func backToMain() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: RecomsModelNavigationHandler

extension ApplicationFlowCoordinator: RecomsModelNavigationHandler {
    
    func openRecomsSettings(_ settings: RecommendationsSettings) {
        let navigationHandler: RecomsSettingsModelNavigationHandler = self
        let controller = container.resolve(RecomsSettingsViewController.self, arguments: settings, navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: RecomsSettingsModelNavigationHandler

extension ApplicationFlowCoordinator: RecomsSettingsModelNavigationHandler {
    
    func backToRecoms(settings: RecommendationsSettings) {
        recomsViewComtroller?.loadRecoms(with: settings)
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: OrderCreatedModelNavigationHandler

extension ApplicationFlowCoordinator: OrderCreatedModelNavigationHandler {
    
    func createOrderItem(completion: @escaping (OrderItem) -> Void) {
        let controller = container.resolve(CreateOrderItemViewController.self, argument: completion)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
