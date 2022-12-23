import Swinject

final class MainFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainViewController.self) { (_, navigationHandler: MainModelNavigationHandler) in
            let model = MainModel(navigationHandler: navigationHandler)
            let viewModel = MainViewModel(model: model)
            
            return MainViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(EcommerceViewController.self) { (_, navigationHandler: EcommerceModelNavigationHandler) in
            let model = EcommerceModel(navigationHandler: navigationHandler)
            let viewModel = EcommerceViewModel(model: model)

            return EcommerceViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProfileViewController.self) { (_, navigationHandler: ProfileModelNavigationHandler) in
            let model = ProfileModel(navigationHandler: navigationHandler)
            let viewModel = ProfileViewModel(model: model)
            
            return ProfileViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(AppInboxViewController.self) { _ in
            let model = AppInboxModel()
            let viewModel = AppInboxViewModel(model: model)
            
            return AppInboxViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(RecomsViewController.self) { (_, navigationHandler: RecomsModelNavigationHandler) in
            let model = RecomsModel(navigationHandler: navigationHandler)
            let viewModel = RecomsViewModel(model: model)
            
            return RecomsViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(
            RecomsSettingsViewController.self
        ) { (_, settings: RecommendationsSettings, navigationHandler: RecomsSettingsModelNavigationHandler) in
            let model = RecomsSettingsModel(settings: settings, navigationHandler: navigationHandler)
            let viewModel = RecomsSettingsViewModel(model: model)
            
            return RecomsSettingsViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductViewedViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
            let model = ProductViewedModel(navigationHandler: navigationHandler)
            let viewModel = ProductViewedViewModel(model: model)
            
            return ProductViewedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductCategoryViewedViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
            let model = ProductCategoryViewedModel(navigationHandler: navigationHandler)
            let viewModel = ProductCategoryViewedViewModel(model: model)
            
            return ProductCategoryViewedViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(ProductAddedToWishlistViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
            let model = ProductAddedToWishlistModel(navigationHandler: navigationHandler)
            let viewModel = ProductAddedToWishlistViewModel(model: model)
            
            return ProductAddedToWishlistViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(CartUpdatedViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
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
        
        container.register(OrderDeliveredViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
            let model = OrderDeliveredModel(navigationHandler: navigationHandler)
            let viewModel = OrderDeliveredViewModel(model: model)
            
            return OrderDeliveredViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(OrderCancelledViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
            let model = OrderCancelledModel(navigationHandler: navigationHandler)
            let viewModel = OrderCancelledViewModel(model: model)
            
            return OrderCancelledViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(SearchRequestViewController.self) { (_, navigationHandler: EcommerceViewsNavigationHandler) in
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
