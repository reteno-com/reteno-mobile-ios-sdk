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
    }
    
}
