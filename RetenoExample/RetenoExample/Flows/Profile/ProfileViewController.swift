//
//  ProfileViewController.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 06.10.2022.
//

import UIKit
import SnapKit

final class ProfileViewController: NiblessViewController {
    
    private let isMultiAccountSwitch = UISwitch()
    private let multiAccountHintLabel = UILabel()
    private let manageAccountsButton = UIButton()
    
    /// Single-account profile; hidden while multi-account mode is on.
    private let profileSection = UIStackView()
    private let formView = ProfileFormView()
    private let clearMarketIdSwitch = UISwitch()
    private let isAnonymousSwitch = UISwitch()
    private let marketingPushEnabledSwitch = UISwitch()
    private let unreadMessagesCountLabel = UILabel()
    private let saveButton = UIButton()
    
    private let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
        fillStoredProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshMultiAccountState()
    }
    
    private func setupHandlers() {
        isMultiAccountSwitch.addTarget(self, action: #selector(isMultiAccountSwitchHandler), for: .valueChanged)
        manageAccountsButton.addTarget(self, action: #selector(manageAccountsAction), for: .touchUpInside)
        clearMarketIdSwitch.addTarget(self, action: #selector(clearMarketIdSwitchHandler), for: .valueChanged)
        isAnonymousSwitch.addTarget(self, action: #selector(isAnonymousSwitchHandler), for: .valueChanged)
        marketingPushEnabledSwitch.addTarget(self, action: #selector(marketingPushEnabledSwitchHandler), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    private func fillStoredProfile() {
        guard let profile = viewModel.storedProfile else { return }
        
        isAnonymousSwitch.isOn = profile.isAnonymous
        formView.setContactsEnabled(!profile.isAnonymous)
        marketingPushEnabledSwitch.isOn = profile.isMarketingPushEnabled
        formView.fill(with: profile.user)
        saveButton.setTitle(NSLocalizedString("createProfile_screen.updateButton", comment: ""), for: .normal)
    }
    
    private func refreshMultiAccountState() {
        let isEnabled = viewModel.isMultiAccountEnabled
        isMultiAccountSwitch.isOn = isEnabled
        multiAccountHintLabel.text = viewModel.currentAccountDescription()
        manageAccountsButton.isHidden = !isEnabled
        profileSection.isHidden = isEnabled
        saveButton.isHidden = isEnabled
    }
    
    @objc
    private func isMultiAccountSwitchHandler(_ sender: UISwitch) {
        view.endEditing(true)
        viewModel.setMultiAccountEnabled(sender.isOn)
        refreshMultiAccountState()
        if sender.isOn {
            viewModel.openAccounts()
        }
    }
    
    @objc
    private func manageAccountsAction(_ button: UIButton) {
        viewModel.openAccounts()
    }
    
    @objc
    private func clearMarketIdSwitchHandler(_ sender: UISwitch) {
        formView.setMarketIdEnabled(!sender.isOn)
        viewModel.updateShouldClearMarketId(sender.isOn)
    }
    
    @objc
    private func isAnonymousSwitchHandler(_ sender: UISwitch) {
        formView.setContactsEnabled(!sender.isOn)
        viewModel.updateIsAnonymous(sender.isOn)
    }
    
    @objc
    private func marketingPushEnabledSwitchHandler(_ sender: UISwitch) {
        viewModel.updateIsMarketingPushEnabled(sender.isOn)
    }
    
    @objc
    private func saveAction(_ button: UIButton) {
        viewModel.saveUser(formView.user)
        viewModel.getUnreadMessagesCount { [weak self] number in
            self?.unreadMessagesCountLabel.text = "\(number)"
        }
        viewModel.getMessages()
    }
    
}

// MARK: - Layout

private extension ProfileViewController {
    
    func setupLayout() {
        title = NSLocalizedString("createProfile_screen.title", comment: "")
        view.backgroundColor = .white
        
        let stack = UIStackView()
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        // Multi-account
        
        stack.addArrangedSubview(makeSwitchRow(
            isMultiAccountSwitch,
            title: NSLocalizedString("createProfile_screen.multiAccountSwitch", comment: "")
        ))
        
        multiAccountHintLabel.font = .systemFont(ofSize: 13.0)
        multiAccountHintLabel.textColor = .darkGray
        multiAccountHintLabel.numberOfLines = 0
        stack.addArrangedSubview(multiAccountHintLabel)
        
        manageAccountsButton.layer.cornerRadius = 8.0
        manageAccountsButton.backgroundColor = .systemBlue
        manageAccountsButton.setTitleColor(.white, for: .normal)
        manageAccountsButton.setTitle(
            NSLocalizedString("createProfile_screen.multiAccount.manageButton", comment: ""),
            for: .normal
        )
        manageAccountsButton.snp.makeConstraints {
            $0.height.equalTo(44.0)
        }
        stack.addArrangedSubview(manageAccountsButton)
        
        // Single-account profile
        
        profileSection.axis = .vertical
        profileSection.spacing = 10.0
        stack.addArrangedSubview(profileSection)
        stack.setCustomSpacing(20.0, after: multiAccountHintLabel)
        
        profileSection.addArrangedSubview(formView)
        profileSection.addArrangedSubview(makeSwitchRow(
            clearMarketIdSwitch,
            title: NSLocalizedString("createProfile_screen.clearMarketIdSwitch", comment: "")
        ))
        profileSection.addArrangedSubview(makeSwitchRow(
            isAnonymousSwitch,
            title: NSLocalizedString("createProfile_screen.anonymousSwitch", comment: "")
        ))
        profileSection.addArrangedSubview(makeSwitchRow(
            marketingPushEnabledSwitch,
            title: NSLocalizedString("createProfile_screen.marketingPushEnabledSwitch", comment: "")
        ))
        
        let messagesCountStackView = UIStackView()
        messagesCountStackView.axis = .horizontal
        messagesCountStackView.distribution = .equalSpacing
        let unreadMessagesTextLabel = UILabel()
        unreadMessagesTextLabel.text = "Unread messages count:"
        messagesCountStackView.addArrangedSubview(unreadMessagesTextLabel)
        messagesCountStackView.addArrangedSubview(unreadMessagesCountLabel)
        profileSection.addArrangedSubview(messagesCountStackView)
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
        saveButton.setTitle(NSLocalizedString("createProfile_screen.saveButton", comment: ""), for: .normal)
        saveButton.backgroundColor = .systemGray
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.layer.cornerRadius = 6.0
    }
    
    func makeSwitchRow(_ switcher: UISwitch, title: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 6.0
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        row.addArrangedSubview(switcher)
        row.addArrangedSubview(label)
        
        return row
    }
    
}
