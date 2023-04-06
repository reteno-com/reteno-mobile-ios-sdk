//
//  RecommendationsCoordinator.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 28.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Swinject

protocol RecomsSettingsModelNavigationHandler {
    
    func backToRecoms(settings: RecommendationsSettings)
    
}

final class RecommendationsCoordinator {
    
    public weak var navigationController: UINavigationController?
    private weak var recomsViewComtroller: RecomsViewController?
    
    private let container: Container
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        container = Container {
            RecommendationsFlowAssembly().assemble(container: $0)
        }
    }
    
    func createFlow() -> UIViewController {
        let handler: RecomsModelNavigationHandler = self
        let controller = container.resolve(RecomsViewController.self, argument: handler)!
        recomsViewComtroller = controller
        return controller
    }
}

// MARK: RecomsModelNavigationHandler

extension RecommendationsCoordinator: RecomsModelNavigationHandler {
    
    func openRecomsSettings(_ settings: RecommendationsSettings) {
        let navigationHandler: RecomsSettingsModelNavigationHandler = self
        let controller = container.resolve(RecomsSettingsViewController.self, arguments: settings, navigationHandler)!
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: RecomsSettingsModelNavigationHandler

extension RecommendationsCoordinator: RecomsSettingsModelNavigationHandler {
    
    func backToRecoms(settings: RecommendationsSettings) {
        recomsViewComtroller?.loadRecoms(with: settings)
        navigationController?.popViewController(animated: true)
    }
    
}
