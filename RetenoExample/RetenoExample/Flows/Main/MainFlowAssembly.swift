import Swinject

final class MainFlowAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(MainViewController.self) { _ in
            let model = MainModel()
            let viewModel = MainViewModel(model: model)
            
            return MainViewController(viewModel: viewModel)
        }.inObjectScope(.transient)
    }
    
}
