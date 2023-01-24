//
//  CreateOrderItemViewController.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 21.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class CreateOrderItemViewController: KeyboardHandlingViewController, AlertPresentable {
    
    private let contentView = UIView()
    private let stack = UIStackView()
    private let idTextField = UITextField()
    private let nameTextField = UITextField()
    private let categoryTextField = UITextField()
    private let quantityTextField = UITextField()
    private let costTextField = UITextField()
    private let urlTextField = UITextField()
    private let imageUrlTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let createButton = UIButton()
    
    private let viewModel: CreateOrderItemViewModel
    
    // MARK: Lifecycle
    
    init(viewModel: CreateOrderItemViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    // MARK: Actions
    
    @objc
    private func createAction(_ sender: UIButton) {
        guard
            let id = idTextField.text, !id.isEmpty,
            let name = nameTextField.text, !name.isEmpty,
            let category = categoryTextField.text, !category.isEmpty,
            let quantity = quantityTextField.text.flatMap({ Double($0) }),
            let cost = costTextField.text.flatMap({ Float($0) }),
            let url = urlTextField.text, !url.isEmpty
        else {
            presentAlert(
                title: NSLocalizedString("common.error.title", comment: ""),
                message: NSLocalizedString("ecommerce.create_order_item_screen.validation_error.missed_required_parameters", comment: "")
            )
            return
        }
        
        let item = OrderItem(
            externalItemId: id,
            name: name,
            category: category,
            quantity: quantity,
            cost: cost,
            url: url,
            imageUrl: imageUrlTextField.text,
            description: descriptionTextField.text
        )
        viewModel.createOrderItem(item)
    }

}

// MARK: Layout

private extension CreateOrderItemViewController {
    
    func setupLayout() {
        title = NSLocalizedString("ecommerce.create_order_item_screen.title", comment: "")
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
            $0.top.equalTo(contentView).offset(20.0)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalToSuperview()
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        stack.addArrangedSubview(idTextField)
        baseSetup(for: idTextField)
        idTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.id", comment: "")
        
        stack.addArrangedSubview(nameTextField)
        baseSetup(for: nameTextField)
        nameTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.name", comment: "")
        
        stack.addArrangedSubview(categoryTextField)
        baseSetup(for: categoryTextField)
        categoryTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.category", comment: "")
        
        stack.addArrangedSubview(quantityTextField)
        baseSetup(for: quantityTextField)
        quantityTextField.keyboardType = .numberPad
        quantityTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.quantity", comment: "")
        
        stack.addArrangedSubview(costTextField)
        baseSetup(for: costTextField)
        costTextField.keyboardType = .numberPad
        costTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.cost", comment: "")
        
        stack.addArrangedSubview(urlTextField)
        baseSetup(for: urlTextField)
        urlTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.url", comment: "")
        
        stack.addArrangedSubview(imageUrlTextField)
        baseSetup(for: imageUrlTextField)
        imageUrlTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.image_url", comment: "")
        
        stack.addArrangedSubview(descriptionTextField)
        baseSetup(for: descriptionTextField)
        descriptionTextField.placeholder = NSLocalizedString("ecommerce.create_order_item_screen.fields.description", comment: "")
        
        createButton.layer.cornerRadius = 8.0
        createButton.backgroundColor = .black
        createButton.setTitleColor(.white, for: .normal)
        createButton.setTitle(NSLocalizedString("common.create",comment: ""), for: .normal)
        createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        view.addSubview(createButton)
        createButton.snp.makeConstraints {
            $0.top.equalTo(scrollView.snp.bottom).offset(16.0)
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
