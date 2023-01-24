//
//  RecommendationsAssembly.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 28.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Swinject

final class RecommendationsFlowAssembly: Assembly {
    
    func assemble(container: Container) {
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
