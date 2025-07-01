//
//  CustomDeviceIdViewController.swift
//  RetenoExample
//
//  Created by George Farafonov on 26.06.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class CustomDeviceIdViewController: NiblessViewController {
    private let deviceIdTextField = CommonTextField()
    
    private let generateIdButton = UIButton()
    private let isCustomDeviceIdSwitch = UISwitch()
    private let saveButton = UIButton()
    
    private let viewModel: CustomDeviceIdViewModel
    
    init(viewModel: CustomDeviceIdViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupHandlers()
        
        isCustomDeviceIdSwitch.isOn = viewModel.isCustomDeviceId()
        deviceIdTextField.text = viewModel.getDeviceId()
    }
    
    private func setupHandlers() {
        isCustomDeviceIdSwitch.addTarget(self, action: #selector(isCustomDeviceIsSwitchHandler), for: .valueChanged)
        generateIdButton.addTarget(self, action: #selector(generateIdAction), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        deviceIdTextField.delegate = self
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        title = "Custom Device ID"
        
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
        deviceIdTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        idStackView.addArrangedSubview(deviceIdTextField)
        
        deviceIdTextField.placeholder = "Device ID"
        deviceIdTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
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
        
        let isCustomDeviceIdStackView = UIStackView()
        isCustomDeviceIdStackView.axis = .horizontal
        isCustomDeviceIdStackView.spacing = 6.0
        let isCustomDeviceIdLabel = UILabel()
        isCustomDeviceIdLabel.text = "Is custom device ID"
        isCustomDeviceIdStackView.addArrangedSubview(isCustomDeviceIdSwitch)
        isCustomDeviceIdStackView.addArrangedSubview(isCustomDeviceIdLabel)
        
        stack.addArrangedSubview(isCustomDeviceIdStackView)
        
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
        deviceIdTextField.text = nil
        deviceIdTextField.resignFirstResponder()
        generateIdButton.isEnabled = sender.isOn
        viewModel.updateIsCustomDeviceId(isCustomDeviceId: sender.isOn)
    }
    
    @objc
    func generateIdAction(_ button: UIButton) {
        let id = viewModel.generateId()
        deviceIdTextField.text = id
    }
    
    @objc
    func saveAction(_ button: UIButton) {
        guard let text = deviceIdTextField.text, !text.isEmpty else { return }
        viewModel.save(deviceId: text.replacingOccurrences(of: " ", with: "-"))
    }
}

extension CustomDeviceIdViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isCustomDeviceIdSwitch.isOn
    }
}
