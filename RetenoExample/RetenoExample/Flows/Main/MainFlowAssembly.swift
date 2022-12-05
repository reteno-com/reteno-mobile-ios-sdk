import Swinject

final class MainFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainViewController.self) { (_, navigationHandler: MainModelNavigationHandler) in
            let model = MainModel(navigationHandler: navigationHandler)
            let viewModel = MainViewModel(model: model)
            
            return MainViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
        
        container.register(MenuViewController.self) { _ in
            let model = MenuModel()
            let viewModel = MenuViewModel(model: model)
            
            return MenuViewController(viewModel: viewModel)
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
    }
    
}
