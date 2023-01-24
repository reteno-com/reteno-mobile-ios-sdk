//
//  OrderCreatedViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class OrderCreatedViewController: KeyboardHandlingViewController {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let externalOrderIdTextField = UITextField()
    private let totalCostTextField = UITextField()
    private let statusTextField = UITextField()
    private let currencyTextField = UITextField()
    private let isForcePushedLabel = UILabel()
    private let isForcePushedSwitch = UISwitch()
    private let sendEventButton = UIButton()
    private let addAttributeButton = UIButton()
    private let addItemButton = UIButton()
    
    private var keysTextFields: [UITextField] = []
    private var valuesTextFields: [UITextField] = []
    
    private let viewModel: OrderCreatedViewModel
    
    // MARK: Lifecycle
    
    init(viewModel: OrderCreatedViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
        
    }
    
    private func mapAttributes() -> [String: String]? {
        let attributesKeys: [String?] = keysTextFields.map { $0.text }
        let attributesValues: [String?] = valuesTextFields.map { $0.text }
        
        guard !attributesKeys.isEmpty, !attributesValues.isEmpty else { return nil }

        var attributes: [String: String] = [:]
        attributesKeys.enumerated().forEach {
            if let key = $0.element,
               !key.isEmpty,
               let value = attributesValues[$0.offset],
               !value.isEmpty {
                attributes[key] = value
            }
        }
        
        return attributes.isEmpty ? nil : attributes
    }
    
    private func setupHandlers() {
        sendEventButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
        addAttributeButton.addTarget(self, action: #selector(addAttribute), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    private func addAttribute(_ sender: UIButton) {
        stack.addArrangedSubview(setupAttribiteTextFields())
    }
    
    @objc
    private func sendEvent(_ sender: UIButton) {
        guard
            let externalOrderId = externalOrderIdTextField.text,
            let totalCost = totalCostTextField.text,
            let status = statusTextField.text,
            !externalOrderId.isEmpty,
            !totalCost.isEmpty,
            !status.isEmpty
        else { return }
        
        viewModel.sendEvent(
            externalOrderId: externalOrderId,
            totalCost: Float(totalCost) ?? 0.0,
            status: status,
            currency: currencyTextField.text,
            attributes: mapAttributes()
        )
        viewModel.backToEcommerce()
    }
    
    @objc
    private func createOrderItem(_ sender: UIButton) {
        viewModel.createOrderItem()
    }
    
}

// MARK: Layout

private extension OrderCreatedViewController {
    
    func setupAttribiteTextFields() -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.distribution = .fillProportionally
        
        let attributeKeyTextField = UITextField()
        stack.addArrangedSubview(attributeKeyTextField)
        baseSetup(for: attributeKeyTextField)
        attributeKeyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.attribute_key", comment: "")
        attributeKeyTextField.snp.makeConstraints {
            $0.width.equalTo(stack).multipliedBy(0.3)
        }
        keysTextFields.append(attributeKeyTextField)
        
        let attributeValueTextField = UITextField()
        stack.addArrangedSubview(attributeValueTextField)
        baseSetup(for: attributeValueTextField)
        attributeValueTextField.placeholder = NSLocalizedString(
            "ecommerce_screen.shared.fields.attribute_value",
            comment: ""
        )
        valuesTextFields.append(attributeValueTextField)
        
        return stack
    }
    
    func setupSwitch(label: UILabel, switcher: UISwitch, labelText: String, switcherIsOn: Bool = false) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        
        label.text = labelText
        stack.addArrangedSubview(label)
        baseSetup(for: label)
        
        stack.addArrangedSubview(switcher)
        switcher.isOn = switcherIsOn
        baseSetup(for: switcher)
        
        return stack
    }
    
    func setupLayout() {
        title = viewModel.title
        view.backgroundColor = .lightGray
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.width.equalToSuperview()
        }
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(contentView.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        stack.addArrangedSubview(externalOrderIdTextField)
        baseSetup(for: externalOrderIdTextField)
        externalOrderIdTextField.placeholder = NSLocalizedString("ecommerce.order_created_screen.fields.order_id", comment: "")
        
        stack.addArrangedSubview(totalCostTextField)
        baseSetup(for: totalCostTextField)
        totalCostTextField.keyboardType = .phonePad
        totalCostTextField.placeholder = NSLocalizedString("ecommerce.order_created_screen.fields.total_cost", comment: "")
        
        stack.addArrangedSubview(statusTextField)
        baseSetup(for: statusTextField)
        statusTextField.placeholder = NSLocalizedString("ecommerce.order_created_screen.fields.status", comment: "")

        stack.addArrangedSubview(currencyTextField)
        baseSetup(for: currencyTextField)
        currencyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.currency", comment: "")
        
        addAttributeButton.layer.cornerRadius = 8.0
        addAttributeButton.backgroundColor = .black
        addAttributeButton.setTitleColor(.white, for: .normal)
        addAttributeButton.setTitle("+", for: .normal)
        addAttributeButton.addTarget(self, action: #selector(addAttribute(_:)), for: .touchUpInside)
        contentView.addSubview(addAttributeButton)
        addAttributeButton.snp.makeConstraints {
            $0.height.width.equalTo(50.0)
            $0.trailing.equalToSuperview().offset(-16.0)
            $0.top.equalTo(stack.snp.bottom).offset(10.0)
            $0.bottom.equalToSuperview()
        }
        
        addItemButton.layer.cornerRadius = 8.0
        addItemButton.backgroundColor = .systemGreen
        addItemButton.setTitleColor(.white, for: .normal)
        addItemButton.setTitle(
            NSLocalizedString("ecommerce.order_created_screen.add_item_button.title", comment: ""),
            for: .normal
        )
        addItemButton.addTarget(self, action: #selector(createOrderItem), for: .touchUpInside)
        view.addSubview(addItemButton)
        addItemButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
            $0.height.equalTo(50.0)
        }
        
        let isForcedPushOption = setupSwitch(
            label: isForcePushedLabel,
            switcher: isForcePushedSwitch,
            labelText: NSLocalizedString("ecommerce_screen.shared.labels.is_force_pushed_label", comment: "")
        )
        view.addSubview(isForcedPushOption)
        isForcedPushOption.snp.makeConstraints {
            $0.top.equalTo(addItemButton.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(20.0)
        }
        
        sendEventButton.layer.cornerRadius = 8.0
        sendEventButton.backgroundColor = .black
        sendEventButton.setTitleColor(.white, for: .normal)
        sendEventButton.setTitle(NSLocalizedString("ecommerce_screen.shared.buttons.send_event_button",comment: ""), for: .normal)
        sendEventButton.addTarget(self, action: #selector(sendEvent(_:)), for: .touchUpInside)
        view.addSubview(sendEventButton)
        sendEventButton.snp.makeConstraints {
            $0.top.equalTo(isForcedPushOption.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20.0)
            $0.height.equalTo(50.0)
        }
    }
    
    func baseSetup(for view: UIView) {
        view.snp.makeConstraints {
            $0.height.equalTo(30.0)
        }
    }
    
    func baseSetup(for textField: UITextField) {
        textField.snp.makeConstraints {
            $0.height.equalTo(30.0)
        }
        textField.textAlignment = .center
        textField.layer.cornerRadius = 8.0
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        
        let doneBar = DoneBar(textField: textField)
        textField.inputAccessoryView = doneBar
    }
    
}
