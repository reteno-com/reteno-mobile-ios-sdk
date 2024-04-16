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
    private let countLabel = UILabel()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setuplayout()
        viewModel.updateCountHandler = { [weak countLabel] count in
            guard let countLabel = countLabel else { return }
            
            countLabel.text = "\(count)"
            countLabel.backgroundColor = count > 0 ? .systemOrange : .gray
        }
    }
    
    // MARK: Actions
    
    @objc
    private func pauseInAppSwitchAction(_ sender: UISwitch) {
        viewModel.pausedInApp(sender.isOn)
    }
        
    @objc
    private func pauseBehaviourInAppSwitchAction(_ sender: UISwitch) {
        viewModel.setPauseBehaviour(sender.isOn)
    }
    
    @objc
    private func ecommerceButtonAction(_ sender: UIButton) {
        viewModel.openEcommerce()
    }
    
    @objc
    private func logEventButtonAction(_ sender: UIButton) {
        viewModel.logCustomEvent()
	}
    
	@objc
    private func profileButtonAction(_ sender: UIButton) {
        viewModel.openProfile()
    }
    
    @objc
    private func inboxButtonAction(_ sender: UIButton) {
        viewModel.openAppInbox()
    }
    
    @objc
    private func recomsButtonAction(_ sender: UIButton) {
        viewModel.openRecoms()
    }
    
    @objc
    private func subscribeOnPushButtonAction(_ sender: UIButton) {
        viewModel.subscribeOnPushNotifications()
    }
    
}

// MARK: - Layout

private extension MainViewController {
    
    func setuplayout() {
        view.backgroundColor = .white
        
        let label = UILabel()
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview().priority(.medium)
        }
        
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .black
        label.text = NSLocalizedString("main_screen.title", comment: "")
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12.0
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(label.snp.bottom).offset(20.0)
            $0.leading.trailing.equalToSuperview().inset(12.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12.0)
        }
        
        let subscribeOnPushButton = UIButton(type: .system)
        subscribeOnPushButton.setTitle(NSLocalizedString("main_screen.subscribe_on_push_button.title", comment: ""), for: .normal)
        subscribeOnPushButton.addTarget(self, action: #selector(subscribeOnPushButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(subscribeOnPushButton)
        baseSetup(for: subscribeOnPushButton)
        subscribeOnPushButton.backgroundColor = .systemGreen
        
        let ecommerceButton = UIButton(type: .system)
        ecommerceButton.setTitle(NSLocalizedString("ecommerce_screen.title", comment: ""), for: .normal)
        ecommerceButton.addTarget(self, action: #selector(ecommerceButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(ecommerceButton)
        baseSetup(for: ecommerceButton)
        
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
        
        let inboxButton = UIButton(type: .system)
        inboxButton.setTitle(NSLocalizedString("inbox_screen.title", comment: ""), for: .normal)
        inboxButton.addTarget(self, action: #selector(inboxButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(inboxButton)
        baseSetup(for: inboxButton)
        setupCountLabel(onView: inboxButton)
        
        let recomsButton = UIButton(type: .system)
        recomsButton.setTitle(NSLocalizedString("recoms_screen.title", comment: ""), for: .normal)
        recomsButton.addTarget(self, action: #selector(recomsButtonAction(_:)), for: .touchUpInside)
        stack.addArrangedSubview(recomsButton)
        baseSetup(for: recomsButton)
        
        stack.addArrangedSubview(makePauseSwitcher())
        stack.addArrangedSubview(makePauseBehaviourSwitcher())
    }
    
    func baseSetup(for button: UIButton) {
        button.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }
        
        button.backgroundColor = .systemGray
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 6.0
    }
    
    func setupCountLabel(onView view: UIView) {
        let containerView = UIView()
        view.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.height.equalTo(30.0)
            $0.width.greaterThanOrEqualTo(30.0)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20.0)
        }
        containerView.layer.cornerRadius = 8.0
        containerView.clipsToBounds = true
        containerView.addSubview(countLabel)
        countLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        countLabel.textColor = .black
        countLabel.textAlignment = .center
    }
    
    func makePauseSwitcher() -> UIView {
        let containerView: UIView = .init()
        containerView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        containerView.layer.cornerRadius = 6.0
        containerView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        let pauseSwitcher: UISwitch = .init()
        pauseSwitcher.addTarget(self, action: #selector(pauseInAppSwitchAction(_:)), for: .valueChanged)
        containerView.addSubview(pauseSwitcher)
        pauseSwitcher.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20.0)
        }
        
        let pauseLabel: UILabel = .init()
        containerView.addSubview(pauseLabel)
        pauseLabel.text = NSLocalizedString("main_screen.paused_in_app", comment: "")
        pauseLabel.textColor = .black
        pauseLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20.0)
        }
        
        return containerView
    }
    
    func makePauseBehaviourSwitcher() -> UIView {
        let containerView: UIView = .init()
        containerView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        containerView.layer.cornerRadius = 6.0
        containerView.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        let pauseSwitcher: UISwitch = .init()
        pauseSwitcher.isOn = true
        pauseSwitcher.addTarget(self, action: #selector(pauseBehaviourInAppSwitchAction(_:)), for: .valueChanged)
        containerView.addSubview(pauseSwitcher)
        pauseSwitcher.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20.0)
        }
        
        let pauseLabel: UILabel = .init()
        containerView.addSubview(pauseLabel)
        pauseLabel.text = NSLocalizedString("main_screen.paused_behaviour_in_app", comment: "")
        pauseLabel.textColor = .black
        pauseLabel.font = .systemFont(ofSize: 16)
        pauseLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8.0)
            $0.leading.equalToSuperview().inset(20.0)
        }
        
        let pauseDescriptionLabel: UILabel = .init()
        containerView.addSubview(pauseDescriptionLabel)
        pauseDescriptionLabel.text = NSLocalizedString("main_screen.paused_behaviour_description", comment: "")
        pauseDescriptionLabel.textColor = .black
        pauseDescriptionLabel.font = .systemFont(ofSize: 14)
        pauseDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(pauseLabel.snp.bottom).offset(2.0)
            $0.leading.equalToSuperview().inset(20.0)
        }
        
        return containerView
    }
    
}
