//
//  CustomInAppURLViewController.swift
//  RetenoExample
//
//  Created by George Farafonov on 02.07.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class CustomInAppURLViewController: NiblessViewController {
    private let linkTextField = CommonTextField()
    private let isCustomLinkSwitch = UISwitch()
    private let saveButton = UIButton()
    
    private let viewModel: CustomInAppURLViewModel
    
    init(viewModel: CustomInAppURLViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupHandlers()
        
        isCustomLinkSwitch.isOn = viewModel.isCustomURL()
        linkTextField.text = viewModel.getCustomURL()
    }
    
    private func setupHandlers() {
        isCustomLinkSwitch.addTarget(self, action: #selector(isCustomDeviceIsSwitchHandler), for: .valueChanged)
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        linkTextField.delegate = self
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        title = "Custom In-App URL"
        
        let stack = UIStackView()
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0

        linkTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(linkTextField)
        
        linkTextField.placeholder = "Path"
        linkTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let isCustomLinkStackView = UIStackView()
        isCustomLinkStackView.axis = .horizontal
        isCustomLinkStackView.spacing = 6.0
        let isCustomLinkLabel = UILabel()
        isCustomLinkLabel.text = "Is custom link"
        isCustomLinkStackView.addArrangedSubview(isCustomLinkSwitch)
        isCustomLinkStackView.addArrangedSubview(isCustomLinkLabel)
        
        stack.addArrangedSubview(isCustomLinkStackView)
        
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
    
    @objc
    private func isCustomDeviceIsSwitchHandler(_ sender: UISwitch) {
        linkTextField.text = nil
        linkTextField.resignFirstResponder()
        viewModel.updateIsCustomURL(isCustomURL: sender.isOn)
    }
    
    @objc
    func saveAction(_ button: UIButton) {
        guard let text = linkTextField.text, !text.isEmpty else { return }
        viewModel.save(customURL: text.replacingOccurrences(of: " ", with: ""))
    }
}

extension CustomInAppURLViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isCustomLinkSwitch.isOn
    }
}

