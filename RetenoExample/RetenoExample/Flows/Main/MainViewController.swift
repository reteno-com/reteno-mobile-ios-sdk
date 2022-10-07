//
//  MainViewController.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 21.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class MainViewController: UIViewController {
    
    private let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Init is not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setuplayout()
    }
    
    // MARK: Actions
    
    @objc
    private func menuButtonAction(_ sender: UIButton) {
        viewModel.openMenu()
    }
    
}

// MARK: - Layout

private extension MainViewController {
    
    func setuplayout() {
        view.backgroundColor = .white
        
        let label = UILabel()
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .black
        label.text = NSLocalizedString("main_screen.title", comment: "")
        
        let menuButton = UIButton(type: .system)
        menuButton.backgroundColor = .systemGray
        menuButton.setTitle(NSLocalizedString("menu_screen.title", comment: ""), for: .normal)
        menuButton.setTitleColor(.black, for: .normal)
        menuButton.layer.cornerRadius = 6.0
        
        menuButton.addTarget(self, action: #selector(menuButtonAction(_:)), for: .touchUpInside)
        view.addSubview(menuButton)
        menuButton.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(80.0)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.4)
            $0.height.equalTo(28.0)
        }
    }
    
}
