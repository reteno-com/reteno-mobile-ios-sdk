//
//  CartUpdatedViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class CartUpdatedViewController: KeyboardHandlingViewController {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let cartIdTextField = CommonTextField()
    private let currencyTextField = CommonTextField()
    private let isForcePushedLabel = UILabel()
    private let isForcePushedSwitch = UISwitch()
    private var productsLabel = UILabel()
    
    private let addNewProductInCartButton = CommonButton()
    private let sendEventButton = CommonButton()

    private var productIdsTextFields: [CommonTextField] = []
    private var productPricesTextFields: [CommonTextField] = []
    private var productQuantityTextFields: [CommonTextField] = []
    private var discountTextFields: [CommonTextField] = []
    private var nameTextFields: [CommonTextField] = []
    private var categoryTextFields: [CommonTextField] = []
    private var attributesKeysTextFields: [[CommonTextField]] = [[]]
    private var attributesValuesTextFields: [[CommonTextField]] = [[]]
    
    private let viewModel: CartUpdatedViewModel
    
    init(viewModel: CartUpdatedViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
    }
    
    private func mapAttributes(at index: Int) -> [String: [String]]? {
        let keysTextFields = attributesKeysTextFields[index]
        let valuesTextFields = attributesValuesTextFields[index]
        
        guard !keysTextFields.isEmpty, !valuesTextFields.isEmpty else { return nil }

        let keys: [String?] = keysTextFields.map { $0.text }
        let values: [[String]?] = valuesTextFields.map { $0.text?.split(separator: ",").map(String.init) }
        
        var attributes: [String: [String]] = [:]
        keys.enumerated().forEach { (index, _) in
            if let key = keys[index], !key.isEmpty,
                let value = values[index], !value.isEmpty {
                attributes[key] = value
            }
        }
        
        return attributes.isEmpty ? nil : attributes
    }
    
    private func mapProductsInCart() -> [ProductInCartPresentable] {
        let transformProductIDs: [String?] = productIdsTextFields.map { $0.text }
        let transformProductPrice: [String?] = productPricesTextFields.map { $0.text }
        let transformProductQuantities: [String?] = productQuantityTextFields.map { $0.text }
        let transformDiscounts: [String?] = discountTextFields.map { $0.text }
        let productNames: [String?] = nameTextFields.map { $0.text }
        let transformCategories: [String?] = categoryTextFields.map { $0.text }
        
        return transformProductIDs.enumerated().compactMap { (index, _) in
            guard
                let productId = transformProductIDs[index], !productId.isEmpty,
                let priceString = transformProductPrice[index], !priceString.isEmpty,
                let quantityString = transformProductQuantities[index], !quantityString.isEmpty,
                let discountString = transformDiscounts[index],
                let name = productNames[index],
                let category = transformCategories[index]
            else {
                return nil
            }
            
            return ProductInCartPresentable(
                productId: productId,
                price: Float(priceString) ?? 0.0,
                quantity: Int(quantityString) ?? 0,
                discount: Float(discountString) ?? 0.0,
                name: name,
                category: category,
                attributes: mapAttributes(at: index)
            )
        }
    }
    
    private func setupHandlers() {
        sendEventButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
        addNewProductInCartButton.addTarget(self, action: #selector(addNewProductInCart), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    func addAttribute(_ sender: UIButton) {
        guard let stack = sender.superview as? UIStackView else { return }
        
        stack.insertArrangedSubview(setupAttribiteTextFields(at: sender.tag), at: stack.arrangedSubviews.endIndex - 2)
    }
    
    @objc
    func addNewProductInCart(_ sender: UIButton) {
        stack.addArrangedSubview(setupNewProductInCartTextFields())
    }
    
    @objc
    func sendEvent(_ sender: UIButton) {
        guard
            let cartIdText = cartIdTextField.text, !cartIdText.isEmpty,
            let productIdText = productIdsTextFields.first?.text, !productIdText.isEmpty,
            let productPriceText = productPricesTextFields.first?.text, !productPriceText.isEmpty,
            let quantityText = productQuantityTextFields.first?.text, !quantityText.isEmpty
        else { return }
        
        viewModel.sendEvent(
            cartID: cartIdText,
            currencyCode: currencyTextField.text,
            isForcePushed: isForcePushedSwitch.isOn,
            products: mapProductsInCart()
        )
        viewModel.backToEcommerce()
    }
    
}

// MARK: Layout

private extension CartUpdatedViewController {
    
    func setupAttribiteTextFields(at index: Int) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20.0
        stack.distribution = .fillProportionally
        
        let attributeKeyTextField = CommonTextField()
        stack.addArrangedSubview(attributeKeyTextField)
        attributeKeyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.attribute_key", comment: "")
        attributeKeyTextField.snp.makeConstraints {
            $0.width.equalTo(stack).multipliedBy(0.3)
        }
        attributesKeysTextFields[index].append(attributeKeyTextField)
        
        let attributeValueTextField = CommonTextField()
        stack.addArrangedSubview(attributeValueTextField)
        attributeValueTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.attribute_value", comment: "")
        attributesValuesTextFields[index].append(attributeValueTextField)
        
        return stack
    }
    
    func setupNewProductInCartTextFields() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10.0
        
        let productIdTextField = CommonTextField()
        stack.addArrangedSubview(productIdTextField)
        productIdTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.new_productId", comment: "")
        productIdsTextFields.append(productIdTextField)
        
        let productPriceTextField = CommonTextField()
        stack.addArrangedSubview(productPriceTextField)
        productPriceTextField.keyboardType = .numberPad
        productPriceTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.new_product_price", comment: "")
        productPricesTextFields.append(productPriceTextField)
        
        let quantityTextField = CommonTextField()
        stack.addArrangedSubview(quantityTextField)
        quantityTextField.keyboardType = .numberPad
        quantityTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.new_quantity", comment: "")
        productQuantityTextFields.append(quantityTextField)
        
        let discountTextField = CommonTextField()
        stack.addArrangedSubview(discountTextField)
        discountTextField.keyboardType = .numberPad
        discountTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.discount", comment: "")
        discountTextFields.append(discountTextField)
        
        let nameTextField = CommonTextField()
        stack.addArrangedSubview(nameTextField)
        nameTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.name", comment: "")
        nameTextFields.append(nameTextField)
        
        let categoryTextField = CommonTextField()
        stack.addArrangedSubview(categoryTextField)
        categoryTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.category", comment: "")
        categoryTextFields.append(categoryTextField)
        
        let addAttributeButton = CommonButton()
        addAttributeButton.tag = attributesKeysTextFields.count - 1
        attributesKeysTextFields.append([])
        attributesValuesTextFields.append([])
        addAttributeButton.setTitle("+", for: .normal)
        addAttributeButton.addTarget(self, action: #selector(addAttribute(_:)), for: .touchUpInside)
        stack.addArrangedSubview(addAttributeButton)
        addAttributeButton.snp.makeConstraints {
            $0.height.width.equalTo(50.0)
            $0.trailing.equalTo(stack)
        }
        
        ReusableViews.setupSeparatorView(stack: stack, color: .darkGray, viewHeight: 1.0)
                
        return stack
    }
    
    func setupLayout() {
        title = NSLocalizedString("ecommerce_screen.cart_updated_button.title", comment: "")
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
        
        stack.addArrangedSubview(cartIdTextField)
        cartIdTextField.placeholder = NSLocalizedString("ecommerce_screen.cart_updated_screen.fields.cartId", comment: "")
        
        stack.addArrangedSubview(currencyTextField)
        currencyTextField.placeholder = NSLocalizedString("ecommerce_screen.shared.fields.currency", comment: "")
        
        stack.addArrangedSubview(productsLabel)
        productsLabel.text = NSLocalizedString("ecommerce_screen.cart_updated_screen.labels.products", comment: "")
        productsLabel.textAlignment = .center
        productsLabel.snp.makeConstraints {
            $0.height.equalTo(15)
        }
        
        stack.addArrangedSubview(setupNewProductInCartTextFields())
        
        contentView.addSubview(addNewProductInCartButton)
        addNewProductInCartButton.snp.makeConstraints {
            $0.height.equalTo(50.0)
            $0.width.equalTo(125.0)
            $0.trailing.equalTo(contentView.snp.trailing).inset(16.0)
            $0.top.equalTo(stack.snp.bottom).inset(-10.0)
            $0.bottom.lessThanOrEqualTo(contentView.snp.bottom)
        }
        addNewProductInCartButton.setTitle(NSLocalizedString("ecommerce_screen.cart_updated_screen.buttons.add_products", comment: ""), for: .normal)
        addNewProductInCartButton.addTarget(self, action: #selector(addNewProductInCart(_:)), for: .touchUpInside)
        
        let isForcedPushOption = ReusableViews.setupSwitch(
            view: view, label: isForcePushedLabel,
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
        sendEventButton.setTitle(NSLocalizedString("ecommerce_screen.shared.buttons.send_event_button", comment: ""), for: .normal)
        sendEventButton.addTarget(self, action: #selector(sendEvent(_:)), for: .touchUpInside)
    }
    
}
