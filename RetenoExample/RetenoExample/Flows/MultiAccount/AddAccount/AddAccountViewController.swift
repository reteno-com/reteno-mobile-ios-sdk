//
//  AddAccountViewController.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class AddAccountViewController: NiblessViewController, AlertPresentable {
    
    private let formView = ProfileFormView()
    private let accountSuffixTextField = CommonTextField()
    private let saveButton = UIButton()
    
    private let viewModel: AddAccountViewModel
    
    init(viewModel: AddAccountViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    @objc
    private func saveAction(_ button: UIButton) {
        view.endEditing(true)
        
        if case .failure(let error) = viewModel.save(formView.user, accountSuffix: accountSuffixTextField.text) {
            presentAlert(with: error)
        }
    }
    
}

// MARK: - Layout

private extension AddAccountViewController {
    
    func setupLayout() {
        title = NSLocalizedString("addAccount_screen.title", comment: "")
        view.backgroundColor = .white
        
        let stack = UIStackView()
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        stack.addArrangedSubview(formView)
        
        stack.addArrangedSubview(accountSuffixTextField)
        accountSuffixTextField.placeholder = NSLocalizedString("createProfile_screen.fields.accountSuffix", comment: "")
        
        let hintLabel = UILabel()
        hintLabel.text = NSLocalizedString("addAccount_screen.hint", comment: "")
        hintLabel.font = .systemFont(ofSize: 13.0)
        hintLabel.textColor = .darkGray
        hintLabel.numberOfLines = 0
        stack.addArrangedSubview(hintLabel)
        
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
