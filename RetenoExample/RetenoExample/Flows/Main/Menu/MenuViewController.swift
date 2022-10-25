//
//  MenuViewController.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 29.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class MenuViewController: NiblessViewController {
    
    private let viewModel: MenuViewModel
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("menu_screen.title", comment: "")
        setuplayout()
    }

}

// MARK: - Layout

private extension MenuViewController {
    
    func setuplayout() {
        view.backgroundColor = .white
    }
    
}
