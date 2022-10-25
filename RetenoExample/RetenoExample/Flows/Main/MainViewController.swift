//
//  MainViewController.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 21.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class MainViewController: NiblessViewController {
    
    private let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        super.init()
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
    
    @objc
    private func logEventButtonAction(_ sender: UIButton) {
        viewModel.logCustomEvent()
	}
    
	@objc
    private func profileButtonAction(_ sender: UIButton) {
        viewModel.openProfile()
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
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12.0
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12.0)
        }
        
        let menuButton = UIButton(type: .system)
        menuButton.setTitle(NSLocalizedString("menu_screen.title", comment: ""), for: .normal)
        menuButton.addTarget(self, action: #selector(menuButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(menuButton)
        baseSetup(for: menuButton)
        
        let profileButton = UIButton(type: .system)
        profileButton.setTitle(NSLocalizedString("createProfile_screen.title", comment: ""), for: .normal)
        profileButton.addTarget(self, action: #selector(profileButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(profileButton)
        baseSetup(for: profileButton)
        
        let logEventButton = UIButton(type: .system)
        logEventButton.setTitle(NSLocalizedString("main_screen.log_event_button.title", comment: ""), for: .normal)
        logEventButton.addTarget(self, action: #selector(logEventButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(logEventButton)
        baseSetup(for: logEventButton)
        logEventButton.backgroundColor = .systemOrange
    }
    
    func baseSetup(for button: UIButton) {
        button.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }
        
        button.backgroundColor = .systemGray
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 6.0
    }
    
}
