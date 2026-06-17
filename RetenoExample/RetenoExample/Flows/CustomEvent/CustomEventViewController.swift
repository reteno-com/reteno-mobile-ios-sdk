//
//  CustomEventViewController.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import UIKit
import SnapKit
import Reteno

final class CustomEventViewController: KeyboardHandlingViewController {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let eventNameTextField = CommonTextField()
    private let parametersStack = UIStackView()
    private let addParameterButton = CommonButton()
    private let logEventButton = CommonButton()
    
    private var parameterRows: [ParameterRow] = []
    
    private let viewModel: CustomEventViewModel
    
    init(viewModel: CustomEventViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
    }
    
    // MARK: - Actions
    
    @objc
    private func addParameterAction() {
        addParameterRow()
    }
    
    @objc
    private func logEventAction() {
        view.endEditing(true)
        
        guard let eventName = eventNameTextField.text, !eventName.isEmpty else {
            presentAlert(message: NSLocalizedString("custom_event_screen.validation.missed_event_name", comment: ""))
            return
        }
        
        viewModel.logEvent(eventTypeKey: eventName, parameters: mapParameters())
    }
    
    // MARK: - Helpers
    
    private func mapParameters() -> [Event.Parameter] {
        parameterRows.compactMap { row in
            guard let name = row.name, !name.isEmpty else { return nil }
            
            return Event.Parameter(name: name, value: row.value)
        }
    }
    
    @discardableResult
    private func addParameterRow() -> ParameterRow {
        let row = ParameterRow()
        row.onRemove = { [weak self] removedRow in
            self?.removeParameterRow(removedRow)
        }
        parameterRows.append(row)
        parametersStack.addArrangedSubview(row)
        
        return row
    }
    
    private func removeParameterRow(_ row: ParameterRow) {
        parameterRows.removeAll { $0 === row }
        parametersStack.removeArrangedSubview(row)
        row.removeFromSuperview()
    }
    
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
    
    private func setupHandlers() {
        addParameterButton.addTarget(self, action: #selector(addParameterAction), for: .touchUpInside)
        logEventButton.addTarget(self, action: #selector(logEventAction), for: .touchUpInside)
    }
}

// MARK: - Layout

private extension CustomEventViewController {
    
    func setupLayout() {
        title = NSLocalizedString("custom_event_screen.title", comment: "")
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(80.0)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView)
            $0.width.equalTo(scrollView)
        }
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalToSuperview().inset(20.0)
            $0.bottom.lessThanOrEqualToSuperview().inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 16.0
        
        let eventNameLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.event_name", comment: "")
        )
        stack.addArrangedSubview(eventNameLabel)
        
        eventNameTextField.placeholder = NSLocalizedString("custom_event_screen.event_name_placeholder", comment: "")
        eventNameTextField.textAlignment = .left
        stack.addArrangedSubview(eventNameTextField)
        
        let parametersLabel = makeSectionLabel(
            text: NSLocalizedString("custom_event_screen.parameters", comment: "")
        )
        stack.addArrangedSubview(parametersLabel)
        
        parametersStack.axis = .vertical
        parametersStack.spacing = 10.0
        stack.addArrangedSubview(parametersStack)
        
        addParameterButton.setTitle(
            NSLocalizedString("custom_event_screen.add_parameter_button.title", comment: ""),
            for: .normal
        )
        addParameterButton.snp.makeConstraints {
            $0.height.equalTo(45.0)
        }
        stack.addArrangedSubview(addParameterButton)
        
        view.addSubview(logEventButton)
        logEventButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
        logEventButton.setTitle(
            NSLocalizedString("custom_event_screen.log_event_button.title", comment: ""),
            for: .normal
        )
    }
    
    func makeSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        
        return label
    }
}

// MARK: - ParameterRow

private final class ParameterRow: UIView {
    
    var onRemove: ((ParameterRow) -> Void)?
    
    var name: String? { nameTextField.text }
    var value: String { valueTextField.text ?? "" }
    
    private let nameTextField = CommonTextField()
    private let valueTextField = CommonTextField()
    private let removeButton = CommonButton()
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func removeAction() {
        onRemove?(self)
    }
    
    private func setupLayout() {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 10.0
        rowStack.alignment = .center
        addSubview(rowStack)
        rowStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameTextField.placeholder = NSLocalizedString("custom_event_screen.parameter_name_placeholder", comment: "")
        nameTextField.textAlignment = .left
        rowStack.addArrangedSubview(nameTextField)
        
        valueTextField.placeholder = NSLocalizedString("custom_event_screen.parameter_value_placeholder", comment: "")
        valueTextField.textAlignment = .left
        rowStack.addArrangedSubview(valueTextField)
        
        nameTextField.snp.makeConstraints {
            $0.width.equalTo(valueTextField)
        }
        
        removeButton.setTitle("-", for: .normal)
        removeButton.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        rowStack.addArrangedSubview(removeButton)
        removeButton.snp.makeConstraints {
            $0.width.height.equalTo(30.0)
        }
    }
}
