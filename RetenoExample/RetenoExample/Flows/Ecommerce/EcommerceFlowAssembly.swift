//
//  EcommerceFlowAssembly.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 27.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Swinject

final class EcommerceFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(EcommerceViewController.self) { (_, navigationHandler: EcommerceFlowNavigationHandler) in
            let model = EcommerceModel(navigationHandler: navigationHandler)
            let viewModel = EcommerceViewModel(model: model)
            
            return EcommerceViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductViewedViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = ProductViewedModel(navigationHandler: navigationHandler)
            let viewModel = ProductViewedViewModel(model: model)
            
            return ProductViewedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductCategoryViewedViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = ProductCategoryViewedModel(navigationHandler: navigationHandler)
            let viewModel = ProductCategoryViewedViewModel(model: model)
            
            return ProductCategoryViewedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductAddedToWishlistViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = ProductAddedToWishlistModel(navigationHandler: navigationHandler)
            let viewModel = ProductAddedToWishlistViewModel(model: model)
            
            return ProductAddedToWishlistViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(CartUpdatedViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = CartUpdatedModel(navigationHandler: navigationHandler)
            let viewModel = CartUpdatedViewModel(model: model)
            
            return CartUpdatedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(
            OrderCreatedViewController.self
        ) { (_, navigationHandler: OrderCreatedModelNavigationHandler, state: OrderCreatedModel.State) in
            let model = OrderCreatedModel(navigationHandler: navigationHandler, state: state)
            let viewModel = OrderCreatedViewModel(model: model)
            
            return OrderCreatedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(OrderDeliveredViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = OrderDeliveredModel(navigationHandler: navigationHandler)
            let viewModel = OrderDeliveredViewModel(model: model)
            
            return OrderDeliveredViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(OrderCancelledViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = OrderCancelledModel(navigationHandler: navigationHandler)
            let viewModel = OrderCancelledViewModel(model: model)
            
            return OrderCancelledViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(SearchRequestViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = SearchRequestModel(navigationHandler: navigationHandler)
            let viewModel = SearchRequestViewModel(model: model)
            
            return SearchRequestViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(CreateOrderItemViewController.self) { (_, completion: @escaping (OrderItem) -> Void) in
            let model = CreateOrderItemModel(completion: completion)
            let viewModel = CreateOrderItemViewModel(model: model)
            
            return CreateOrderItemViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
    }
}
