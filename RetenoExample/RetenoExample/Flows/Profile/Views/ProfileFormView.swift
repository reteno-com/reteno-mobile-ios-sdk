//
//  ProfileFormView.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

/// Contact fields shared by the "Create profile" and "Add account" screens.
final class ProfileFormView: UIStackView {
    
    private let externalIdTextField = CommonTextField()
    private let firstNameTextField = CommonTextField()
    private let lastNameTextField = CommonTextField()
    private let phoneTextField = CommonTextField()
    private let emailTextField = CommonTextField()
    private let marketIdTextField = CommonTextField()
    private let generateIdButton = UIButton()
    
    private static let allowedMarketIdCharacters = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    )
    
    /// Current field values; empty fields are `nil`.
    var user: User {
        User(
            id: externalIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            firstName: nonEmpty(firstNameTextField.text),
            lastName: nonEmpty(lastNameTextField.text),
            phone: nonEmpty(phoneTextField.text),
            email: nonEmpty(emailTextField.text),
            marketId: nonEmpty(marketIdTextField.text)
        )
    }
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
        generateIdButton.addTarget(self, action: #selector(generateIdAction), for: .touchUpInside)
        marketIdTextField.addTarget(self, action: #selector(marketIdHandler), for: .editingChanged)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(with user: User) {
        externalIdTextField.text = user.id
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        phoneTextField.text = user.phone
        emailTextField.text = user.email
        marketIdTextField.text = user.marketId
    }
    
    func setMarketIdEnabled(_ isEnabled: Bool) {
        if !isEnabled {
            marketIdTextField.text = nil
        }
        marketIdTextField.isEnabled = isEnabled
    }
    
    /// Anonymous contacts can't have a phone or an email.
    func setContactsEnabled(_ isEnabled: Bool) {
        [phoneTextField, emailTextField].forEach {
            $0.text = nil
            $0.isEnabled = isEnabled
        }
    }
    
    @objc
    private func generateIdAction(_ button: UIButton) {
        externalIdTextField.text = UUID().uuidString
    }
    
    @objc
    private func marketIdHandler(_ textField: UITextField) {
        let rawText = textField.text ?? ""
        let filtered = String(rawText.unicodeScalars.filter { Self.allowedMarketIdCharacters.contains($0) })
        if filtered != rawText {
            textField.text = filtered
        }
    }
    
    private func nonEmpty(_ text: String?) -> String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return nil }
        
        return text
    }
    
}

// MARK: - Layout

private extension ProfileFormView {
    
    func setupLayout() {
        axis = .vertical
        spacing = 10.0
        
        let idStackView = UIStackView()
        idStackView.axis = .horizontal
        idStackView.distribution = .fill
        idStackView.spacing = 8.0
        addArrangedSubview(idStackView)
        
        externalIdTextField.placeholder = NSLocalizedString("createProfile_screen.fields.externalId", comment: "")
        externalIdTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        externalIdTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        idStackView.addArrangedSubview(externalIdTextField)
        
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
        
        addArrangedSubview(firstNameTextField)
        firstNameTextField.keyboardType = .namePhonePad
        firstNameTextField.placeholder = NSLocalizedString("createProfile_screen.fields.firstName", comment: "")
        
        addArrangedSubview(lastNameTextField)
        lastNameTextField.keyboardType = .namePhonePad
        lastNameTextField.placeholder = NSLocalizedString("createProfile_screen.fields.lastName", comment: "")
        
        addArrangedSubview(phoneTextField)
        phoneTextField.keyboardType = .phonePad
        phoneTextField.placeholder = NSLocalizedString("createProfile_screen.fields.phone", comment: "")
        
        addArrangedSubview(emailTextField)
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = NSLocalizedString("createProfile_screen.fields.email", comment: "")
        
        addArrangedSubview(marketIdTextField)
        marketIdTextField.keyboardType = .asciiCapable
        marketIdTextField.placeholder = NSLocalizedString("createProfile_screen.fields.marketId", comment: "")
    }
    
}
