//
//  ProductCategoryViewedViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class ProductCategoryViewedViewController: NiblessViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()
    private let categoryIdTextField = UITextField()
    private let isForcePushedLabel = UILabel()
    private let isForcePushedSwitch = UISwitch()
    private let sendEventButton = UIButton()
    private let addAttributeButton = UIButton()
    private var keysTextFields: [UITextField] = []
    private var valuesTextFields: [UITextField] = []
    
    private let viewModel: ProductCategoryViewedViewModel
    
    init(viewModel: ProductCategoryViewedViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let info = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue {
            let keyboardFrame = view.convert(info.cgRectValue, from: nil)
            scrollView.contentInset.bottom = keyboardFrame.size.height + 20
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    
    @objc
    func addAttribute(_ sender: UIButton) {
        stack.addArrangedSubview(setupAttribiteTextFields())
    }
    
    @objc
    func sendEvent(_ sender: UIButton) {
        guard
            let categoryIdText = categoryIdTextField.text,
            !categoryIdText.isEmpty
        else { return }
        
        viewModel.sendEvent(
            categoryId: categoryIdText,
            attributes: mapAttributesDictionary(),
            isForcePushed: isForcePushedSwitch.isOn
        )
        
        viewModel.backToEcommerce()
    }
    
    private func mapAttributesDictionary() -> [String: [String]]? {
        var textDictionary: [String: [String]]? = nil
        let transformKeys: [String?] = keysTextFields.map { $0.text }
        let transformValues: [[String]?] = valuesTextFields.map { $0.text?.split(separator: ",").map(String.init) }
        
        if !transformKeys.isEmpty, !transformValues.isEmpty {
            textDictionary = [:]
            
            for (index, element) in transformKeys.enumerated() {
                if let key = element, let value = transformValues[index], !key.isEmpty, !value.isEmpty {
                    textDictionary![key] = value
                }
            }
        }
        return textDictionary
    }
    
    private func setupHandlers() {
        sendEventButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
        addAttributeButton.addTarget(self, action: #selector(addAttribute), for: .touchUpInside)
    }
    
}

// MARK: - Layout

private extension ProductCategoryViewedViewController {
    
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
        title = NSLocalizedString("ecommerce_screen.product_category_viewed_button.title", comment: "")
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
        
        stack.addArrangedSubview(categoryIdTextField)
        baseSetup(for: categoryIdTextField)
        categoryIdTextField.placeholder = NSLocalizedString("ecommerce_screen.category_viewed_screen.fields.categoryId", comment: "")
        
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
        sendEventButton.setTitle(NSLocalizedString("ecommerce_screen.shared.buttons.send_event_button", comment: ""), for: .normal)
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
