//
//  ProductViewedViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 14.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class ProductViewedViewController: KeyboardHandlingViewController {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let productIdTextField = UITextField()
    private let productPriceTextField = UITextField()
    private let currencyTextField = UITextField()
    private let isInStockLabel = UILabel()
    private let isForcePushedLabel = UILabel()
    private let isInStockSwitch = UISwitch()
    private let isForcePushedSwitch = UISwitch()
    private let sendEventButton = UIButton()
    private let addAttributeButton = UIButton()
    private var keysTextFields: [UITextField] = []
    private var valuesTextFields: [UITextField] = []
    
    private let viewModel: ProductViewedViewModel
    
    init(viewModel: ProductViewedViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
    }
    
    @objc
    func addAttribute(_ sender: UIButton) {
        stack.addArrangedSubview(setupAttribiteTextFields())
    }
    
    @objc
    func sendEvent(_ sender: UIButton) {
        guard
            let productIdText = productIdTextField.text,
            let productPriceText = productPriceTextField.text,
            !productIdText.isEmpty || !productPriceText.isEmpty
        else { return }
        
        viewModel.sendEvent(
            productID: productIdText,
            price: Float(productPriceText) ?? 0.00,
            isInStock: isInStockSwitch.isOn,
            attributes: mapAttributes(),
            currency: currencyTextField.text,
            isForcePushed: isForcePushedSwitch.isOn
        )
        viewModel.backToEcommerce()
    }
    
    private func mapAttributes() -> [String: [String]]? {
        let attributesKeys: [String?] = keysTextFields.map { $0.text }
        let attributesValues: [[String]?] = valuesTextFields.map { $0.text?.components(separatedBy: ",") }
        
        guard !attributesKeys.isEmpty, !attributesValues.isEmpty else { return nil }

        var attributes: [String: [String]] = [:]
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
    
}

// MARK: - Layout

private extension ProductViewedViewController {
    
    func setupAttribiteTextFields() -> UIView {
        let stack = UIStackView()
        let attributeKeyTextField = UITextField()
        let attributeValueTextField = UITextField()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.distribution = .fillProportionally
        
        stack.addArrangedSubview(attributeKeyTextField)
        baseSetup(for: attributeKeyTextField)
        attributeKeyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.attribute_key", comment: "")
        attributeKeyTextField.snp.makeConstraints {
            $0.width.equalTo(stack).multipliedBy(0.3)
        }
        
        stack.addArrangedSubview(attributeValueTextField)
        baseSetup(for: attributeValueTextField)
        attributeValueTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.attribute_value", comment: "")
        keysTextFields.append(attributeKeyTextField)
        valuesTextFields.append(attributeValueTextField)
        return stack
    }
    
    func setupSwitch(label: UILabel, switcher: UISwitch, labelText: String, switcherIsOn: Bool = false) -> UIView {
        let stack = UIStackView()
        view.addSubview(stack)
        stack.axis = .horizontal
        label.text = labelText
        
        stack.addArrangedSubview(label)
        baseSetup(for: label)
        label.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(20.0)
        }
        
        stack.addArrangedSubview(switcher)
        switcher.isOn = switcherIsOn
        baseSetup(for: switcher)
        switcher.snp.makeConstraints {
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).inset(20.0)
        }
        
        return stack
    }
    
    func setupLayout() {
        title = NSLocalizedString("ecommerce_screen.product_viewed_button.title", comment: "")
        view.backgroundColor = .lightGray
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(140.0)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.left.right.equalTo(scrollView)
            $0.width.top.bottom.equalTo(scrollView)
        }
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(contentView.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        stack.addArrangedSubview(productIdTextField)
        baseSetup(for: productIdTextField)
        productIdTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.productId", comment: "")
        
        stack.addArrangedSubview(productPriceTextField)
        baseSetup(for: productPriceTextField)
        productPriceTextField.keyboardType = .numberPad
        productPriceTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.product_price", comment: "")
        
        stack.addArrangedSubview(currencyTextField)
        baseSetup(for: currencyTextField)
        currencyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.currency", comment: "")
        
        stack.addArrangedSubview(
            setupSwitch(
                label: isInStockLabel,
                switcher: isInStockSwitch,
                labelText: NSLocalizedString( "ecommerce_screen.shared.labels.is_in_stock_label", comment: "" ),
                switcherIsOn: true
            )
        )
        
        contentView.addSubview(addAttributeButton)
        addAttributeButton.snp.makeConstraints {
            $0.height.equalTo(50.0)
            $0.width.equalTo(50.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
            $0.top.equalTo(stack.snp.bottom).inset(-10.0)
            $0.bottom.lessThanOrEqualTo(contentView.snp.bottom)
        }
        addAttributeButton.layer.cornerRadius = 8.0
        addAttributeButton.backgroundColor = .black
        addAttributeButton.setTitleColor(.white, for: .normal)
        addAttributeButton.setTitle("+", for: .normal)
        addAttributeButton.addTarget(self, action: #selector(addAttribute(_:)), for: .touchUpInside)
        
        let isForcedPushOption = setupSwitch(
            label: isForcePushedLabel,
            switcher: isForcePushedSwitch,
            labelText: NSLocalizedString("ecommerce_screen.shared.labels.is_force_pushed_label", comment: "")
        )
        
        view.addSubview(isForcedPushOption)
        isForcedPushOption.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(90.0)
        }
        
        view.addSubview(sendEventButton)
        sendEventButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
        
        sendEventButton.layer.cornerRadius = 8.0
        sendEventButton.backgroundColor = .black
        sendEventButton.setTitleColor(.white, for: .normal)
        sendEventButton.setTitle(NSLocalizedString("ecommerce_screen.shared.buttons.send_event_button",comment: ""), for: .normal)
        sendEventButton.addTarget(self, action: #selector(sendEvent(_:)), for: .touchUpInside)
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
