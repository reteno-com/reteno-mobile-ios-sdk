import Swinject

final class MainFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainViewController.self) { (_, navigationHandler: MainModelNavigationHandler) in
            let model = MainModel(navigationHandler: navigationHandler)
            let viewModel = MainViewModel(model: model)
            
            return MainViewController(viewModel: viewModel)
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
        
        container.register(CustomDeviceIdViewController.self) { _ in
            let model = CustomDeviceIdModel()
            let viewModel = CustomDeviceIdViewModel(model: model)
            
            return CustomDeviceIdViewController(viewModel: viewModel)
        }
        
        container.register(CustomInAppURLViewController.self) { _ in
            let model = CustomInAppURLModel()
            let viewModel = CustomInAppURLViewModel(model: model)
            
            return CustomInAppURLViewController(viewModel: viewModel)
        }
    }
    
}
