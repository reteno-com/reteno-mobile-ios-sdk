//
//  ProfileViewController.swift
//  RetenoExample
//
//  Created by Serhii Prykhodko on 06.10.2022.
//

import UIKit
import SnapKit

final class ProfileViewController: NiblessViewController {
    
    private let externalIdTextField = CommonTextField()
    private let firstNameTextField = CommonTextField()
    private let lastNameTextField = CommonTextField()
    private let phoneTextField = CommonTextField()
    private let emailTextField = CommonTextField()
    private let accountSuffixField = CommonTextField()
    private let isAnonymousSwitch = UISwitch()
    
    private let unreadMessagesCountLabel = UILabel()
    
    private let generateIdButton = UIButton()
    private let saveButton = UIButton()
    
    private let unreadMessagesCount: Int = 0
    
    private let viewModel: ProfileViewModel
    
    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
    }
    
    private func setupHandlers() {
        externalIdTextField.addTarget(self, action: #selector(externalIdHandler), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(firstNameHandler), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(lastNameHandler), for: .editingChanged)
        accountSuffixField.addTarget(self, action: #selector(accountSuffixHandler), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(phoneHandler), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailHandler), for: .editingChanged)
        isAnonymousSwitch.addTarget(self, action: #selector(isAnonymousSwitchHandler), for: .valueChanged)
        generateIdButton.addTarget(self, action: #selector(generateIdAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    @objc
    func externalIdHandler(_ textField: UITextField) {
        viewModel.updateExternalId(textField.text)
    }
    
    @objc
    func firstNameHandler(_ textField: UITextField) {
        viewModel.updateFirstName(textField.text ?? "")
    }
    
    @objc
    func accountSuffixHandler(_ textField: UITextField) {
        viewModel.updateAccountSuffix(textField.text?.replacingOccurrences(of: " ", with: "-") ?? "")
    }
    
    @objc
    func lastNameHandler(_ textField: UITextField) {
        viewModel.updateLastName(textField.text ?? "")
    }
    
    @objc
    func phoneHandler(_ textField: UITextField) {
        viewModel.updatePhone(textField.text ?? "")
    }
    
    @objc
    func emailHandler(_ textField: UITextField) {
        viewModel.updateEmail(textField.text ?? "")
    }
    
    @objc
    private func isAnonymousSwitchHandler(_ sender: UISwitch) {
        phoneTextField.text = nil
        viewModel.updatePhone(phoneTextField.text ?? "")
        emailTextField.text = nil
        viewModel.updateEmail(emailTextField.text ?? "")
        viewModel.updateIsAnonymous(sender.isOn)
    }
    
    @objc
    func generateIdAction(_ button: UIButton) {
        let id = viewModel.generateId()
        externalIdTextField.text = id
        viewModel.updateExternalId(id)
    }
    
    @objc
    func saveAction(_ button: UIButton) {
        viewModel.saveUser()
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
        
        let idStackView = UIStackView()
        idStackView.axis = .horizontal
        idStackView.distribution = .fill
        idStackView.spacing = 8.0
        stack.addArrangedSubview(idStackView)
        
        externalIdTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        idStackView.addArrangedSubview(externalIdTextField)
        
        externalIdTextField.placeholder = NSLocalizedString("createProfile_screen.fields.externalId", comment: "")
        externalIdTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        generateIdButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: 4.0)
        generateIdButton.layer.cornerRadius = 8.0
        generateIdButton.backgroundColor = .systemBlue
        generateIdButton.setTitleColor(.white, for: .normal)
        generateIdButton.setTitle(NSLocalizedString("createProfile_screen.generateButton", comment: ""), for: .normal)
        generateIdButton.snp.makeConstraints {
            $0.height.equalTo(30.0)
        }
        generateIdButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        idStackView.addArrangedSubview(generateIdButton)
        
        stack.addArrangedSubview(firstNameTextField)
        firstNameTextField.keyboardType = .namePhonePad
        firstNameTextField.placeholder = NSLocalizedString("createProfile_screen.fields.firstName", comment: "")
        
        stack.addArrangedSubview(lastNameTextField)
        lastNameTextField.keyboardType = .namePhonePad
        lastNameTextField.placeholder = NSLocalizedString("createProfile_screen.fields.lastName", comment: "")
        
        stack.addArrangedSubview(phoneTextField)
        phoneTextField.keyboardType = .phonePad
        phoneTextField.placeholder = NSLocalizedString("createProfile_screen.fields.phone", comment: "")
        
        stack.addArrangedSubview(emailTextField)
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = NSLocalizedString("createProfile_screen.fields.email", comment: "")
        
        stack.addArrangedSubview(accountSuffixField)
        accountSuffixField.placeholder = "Account suffix"
        

        let isAnonymousStackView = UIStackView()
        isAnonymousStackView.axis = .horizontal
        isAnonymousStackView.spacing = 6.0
        let isAnonymousLabel = UILabel()
        isAnonymousLabel.text = NSLocalizedString("createProfile_screen.anonymousSwitch", comment: "")
        isAnonymousStackView.addArrangedSubview(isAnonymousSwitch)
        isAnonymousStackView.addArrangedSubview(isAnonymousLabel)
        
        stack.addArrangedSubview(isAnonymousStackView)
        
        let messagesCountStackView = UIStackView()
        messagesCountStackView.axis = .horizontal
        messagesCountStackView.distribution = .equalSpacing
        let unreadMessagesTextLabel = UILabel()
        unreadMessagesTextLabel.text = "Unread messages count:"
        messagesCountStackView.addArrangedSubview(unreadMessagesTextLabel)
        messagesCountStackView.addArrangedSubview(unreadMessagesCountLabel)
        
        stack.addArrangedSubview(messagesCountStackView)
        
        
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

}
