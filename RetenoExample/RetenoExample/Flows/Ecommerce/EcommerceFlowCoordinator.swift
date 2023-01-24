//
//  EcommerceCoordinator.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 27.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Swinject

protocol EcommerceFlowNavigationHandler {
    
    func openProductViewed()
    func openProductCategoryViewed()
    func openProductAddedToWishlist()
    func openCartUpdated()
    func openOrderCreated()
    func openOrderUpdated()
    func openOrderDelivered()
    func openOrderCancelled()
    func openSearchRequest()
    
}

final class EcommerceFlowCoordinator {
    
    public weak var navigationController: UINavigationController?
    
    private let container: Container
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        container = Container {
            EcommerceFlowAssembly().assemble(container: $0)
        }
    }
    
    func createFlow() -> UIViewController {
        let handler: EcommerceFlowNavigationHandler = self
        let controller = container.resolve(EcommerceViewController.self, argument: handler)!
        return controller
    }
}

extension EcommerceFlowCoordinator: EcommerceFlowNavigationHandler {
    
    public func openProductViewed() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(ProductViewedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openProductCategoryViewed() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(ProductCategoryViewedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openProductAddedToWishlist() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(ProductAddedToWishlistViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openCartUpdated() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(CartUpdatedViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openOrderCreated() {
        let navigationHandler: OrderCreatedModelNavigationHandler = self
        let controller = container.resolve(
            OrderCreatedViewController.self,
            arguments: navigationHandler, OrderCreatedModel.State.create
        )!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openOrderUpdated() {
        let navigationHandler: OrderCreatedModelNavigationHandler = self
        let controller = container.resolve(
            OrderCreatedViewController.self,
            arguments: navigationHandler, OrderCreatedModel.State.update
        )!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openOrderDelivered() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(OrderDeliveredViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openOrderCancelled() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(OrderCancelledViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }

    public func openSearchRequest() {
        let navigationHandler: EcommerceModelNavigationHandler = self
        let controller = container.resolve(SearchRequestViewController.self, argument: navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension EcommerceFlowCoordinator: EcommerceModelNavigationHandler {
    
    func backToEcommerce() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: OrderCreatedModelNavigationHandler

extension EcommerceFlowCoordinator: OrderCreatedModelNavigationHandler {
    
    func createOrderItem(completion: @escaping (OrderItem) -> Void) {
        let controller = container.resolve(CreateOrderItemViewController.self, argument: completion)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
    }
    
}
