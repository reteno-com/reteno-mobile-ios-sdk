//
//  SessionConfigViewController.swift
//  RetenoExample
//
//  Created by George Farafonov on 16.04.2026.
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class SessionConfigViewController: NiblessViewController {
    
    private let sessionDurationTextField = CommonTextField()
    private let startReportingSwitch = UISwitch()
    private let endReportingSwitch = UISwitch()
    private let foregroundLifecycleReportingSwitch = UISwitch()
    private let saveButton = UIButton()
    
    private let viewModel: SessionConfigViewModel
    
    init(viewModel: SessionConfigViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
        applyCurrentValues()
    }
    
    // MARK: - Setup
    
    private func applyCurrentValues() {
        sessionDurationTextField.text = String(Int(viewModel.sessionDuration))
        startReportingSwitch.isOn = viewModel.isSessionStartReportingEnabled
        endReportingSwitch.isOn = viewModel.isSessionEndReportingEnabled
        foregroundLifecycleReportingSwitch.isOn = viewModel.isApplicationForegroundLifecycleReportingEnabled
    }
    
    private func setupHandlers() {
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        title = NSLocalizedString("session_config_screen.title", comment: "")
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16.0
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        
        stack.addArrangedSubview(makeSessionDurationRow())
        stack.addArrangedSubview(makeSwitchRow(
            title: NSLocalizedString("session_config_screen.start_reporting", comment: ""),
            switchControl: startReportingSwitch
        ))
        stack.addArrangedSubview(makeSwitchRow(
            title: NSLocalizedString("session_config_screen.end_reporting", comment: ""),
            switchControl: endReportingSwitch
        ))
        stack.addArrangedSubview(makeSwitchRow(
            title: NSLocalizedString("session_config_screen.application_foreground_lifecycle_reporting", comment: ""),
            switchControl: foregroundLifecycleReportingSwitch
        ))
        
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
    
    private func makeSessionDurationRow() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6.0
        
        let label = UILabel()
        label.text = NSLocalizedString("session_config_screen.session_duration", comment: "")
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        container.addArrangedSubview(label)
        
        sessionDurationTextField.placeholder = "300"
        sessionDurationTextField.keyboardType = .numberPad
        sessionDurationTextField.textAlignment = .left
        container.addArrangedSubview(sessionDurationTextField)
        
        return container
    }
    
    private func makeSwitchRow(title: String, switchControl: UISwitch) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12.0
        
        let label = UILabel()
        label.text = title
        label.textColor = .black
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(label)
        
        switchControl.setContentHuggingPriority(.required, for: .horizontal)
        row.addArrangedSubview(switchControl)
        
        return row
    }
    
    // MARK: - Actions
    
    @objc
    private func saveAction() {
        sessionDurationTextField.resignFirstResponder()
        
        let sessionDuration = TimeInterval(sessionDurationTextField.text ?? "") ?? 0
        viewModel.save(
            sessionDuration: sessionDuration,
            isSessionStartReportingEnabled: startReportingSwitch.isOn,
            isSessionEndReportingEnabled: endReportingSwitch.isOn,
            isApplicationForegroundLifecycleReportingEnabled: foregroundLifecycleReportingSwitch.isOn
        )
        
        presentRestartAlert()
    }
    
    private func presentRestartAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("session_config_screen.restart_alert.title", comment: ""),
            message: NSLocalizedString("session_config_screen.restart_alert.message", comment: ""),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("common.ok", comment: ""),
            style: .default
        ))
        present(alert, animated: true)
    }
}
