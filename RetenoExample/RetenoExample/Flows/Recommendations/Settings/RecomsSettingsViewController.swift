//
//  RecomsSettingsViewController.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 14.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class RecomsSettingsViewController: NiblessViewController {
    
    private let variantIdTextField = UITextField()
    private let categoryIdTextField = UITextField()
    private let productsIdsTextField = UITextField()
    private let filterNameTextField = UITextField()
    private let filterValuesTextField = UITextField()
    private let addFilterButton = UIButton(type: .system)
    private let clearFiltersButton = UIButton(type: .system)
    private let getRecomsButton = UIButton(type: .system)
    
    private let viewModel: RecomsSettingsViewModel
    
    // MARK: Lifecycle
    
    init(viewModel: RecomsSettingsViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupHandlers()
    }
    
    // MARK: Setup handlers
    
    private func setupHandlers() {
        variantIdTextField.addTarget(self, action: #selector(variantIdHandler), for: .editingChanged)
        categoryIdTextField.addTarget(self, action: #selector(categoryIdHandler), for: .editingChanged)
        productsIdsTextField.addTarget(self, action: #selector(productsIdsHandler), for: .editingChanged)
        filterNameTextField.addTarget(self, action: #selector(filterHandler), for: .editingChanged)
        filterValuesTextField.addTarget(self, action: #selector(filterHandler), for: .editingChanged)
        addFilterButton.addTarget(self, action: #selector(addFilterAction), for: .touchUpInside)
        clearFiltersButton.addTarget(self, action: #selector(clearFiltersAction), for: .touchUpInside)
        getRecomsButton.addTarget(self, action: #selector(getRecomsAction), for: .touchUpInside)
    }
    
    // MARK: Actions
    
    @objc
    func variantIdHandler(_ textField: UITextField) {
        viewModel.updateVariantId(textField.text ?? "")
    }
    
    @objc
    func categoryIdHandler(_ textField: UITextField) {
        viewModel.updateCategory(textField.text)
    }
    
    @objc
    func productsIdsHandler(_ textField: UITextField) {
        let ids = (textField.text ?? "")
            .replacingOccurrences(of: " ", with: "")
            .components(separatedBy: ",")
        viewModel.updateProductsIds(ids)
    }
    
    @objc
    func filterHandler(_ textField: UITextField) {
        let name = filterNameTextField.text ?? ""
        let values = filterValuesTextField.text ?? ""
        addFilterButton.isEnabled = !name.isEmpty && !values.isEmpty
    }
    
    @objc
    func addFilterAction(_ button: UIButton) {
        let values = (filterValuesTextField.text ?? "").components(separatedBy: ",")
        viewModel.addFilter(name: filterNameTextField.text ?? "", values: values)
        filterNameTextField.text = nil
        filterValuesTextField.text = nil
    }
    
    @objc
    func clearFiltersAction(_ button: UIButton) {
        viewModel.clearFilters()
    }
    
    @objc
    func getRecomsAction(_ button: UIButton) {
        viewModel.getRecoms()
    }

}

// MARK: - Layout

private extension RecomsSettingsViewController {
    
    func setupLayout() {
        title = NSLocalizedString("recoms_settings_screen.title", comment: "")
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = .groupTableViewBackground
        }
        
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        stackView.axis = .vertical
        stackView.spacing = 10.0
        
        stackView.addArrangedSubview(variantIdTextField)
        baseSetup(for: variantIdTextField)
        variantIdTextField.keyboardType = .default
        variantIdTextField.placeholder = NSLocalizedString("recoms_settings_screen.fields.variant_id", comment: "")
        variantIdTextField.text = viewModel.settings.variantId
        
        stackView.addArrangedSubview(categoryIdTextField)
        baseSetup(for: categoryIdTextField)
        categoryIdTextField.keyboardType = .default
        categoryIdTextField.placeholder = NSLocalizedString("recoms_settings_screen.fields.category", comment: "")
        categoryIdTextField.text = viewModel.settings.category
        
        stackView.addArrangedSubview(productsIdsTextField)
        baseSetup(for: productsIdsTextField)
        productsIdsTextField.keyboardType = .default
        productsIdsTextField.placeholder = NSLocalizedString("recoms_settings_screen.fields.products_ids", comment: "")
        productsIdsTextField.text = viewModel.settings.productsIds.joined(separator: ",")
        stackView.setCustomSpacing(60.0, after: productsIdsTextField)
        
        let infoLabel = UILabel()
        infoLabel.numberOfLines = 0
        infoLabel.text = NSLocalizedString("recoms_settings_screen.filters_info", comment: "")
        infoLabel.font = UIFont.systemFont(ofSize: 14.0,weight: .light)
        stackView.addArrangedSubview(infoLabel)
        
        stackView.addArrangedSubview(filterNameTextField)
        baseSetup(for: filterNameTextField)
        filterNameTextField.keyboardType = .default
        filterNameTextField.placeholder = NSLocalizedString("recoms_settings_screen.fields.filter_name", comment: "")
        
        stackView.addArrangedSubview(filterValuesTextField)
        baseSetup(for: filterValuesTextField)
        filterValuesTextField.keyboardType = .default
        filterValuesTextField.placeholder = NSLocalizedString("recoms_settings_screen.fields.filter_values", comment: "")
        
        stackView.addArrangedSubview(addFilterButton)
        addFilterButton.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }
        addFilterButton.isEnabled = false
        addFilterButton.layer.cornerRadius = 8.0
        addFilterButton.backgroundColor = .black
        addFilterButton.setTitleColor(.white, for: .normal)
        addFilterButton.setTitle(NSLocalizedString("recoms_settings_screen.add_filter_button.title", comment: ""), for: .normal)
        
        stackView.addArrangedSubview(clearFiltersButton)
        clearFiltersButton.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }
        clearFiltersButton.layer.cornerRadius = 8.0
        clearFiltersButton.layer.borderColor = UIColor.black.cgColor
        clearFiltersButton.layer.borderWidth = 2.0
        clearFiltersButton.backgroundColor = .white
        clearFiltersButton.setTitleColor(.black, for: .normal)
        clearFiltersButton.setTitle(NSLocalizedString("recoms_settings_screen.clear_filters_button.title", comment: ""), for: .normal)
        
        view.addSubview(getRecomsButton)
        getRecomsButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
        getRecomsButton.layer.cornerRadius = 8.0
        getRecomsButton.backgroundColor = .black
        getRecomsButton.setTitleColor(.white, for: .normal)
        getRecomsButton.setTitle(NSLocalizedString("recoms_settings_screen.get_recoms_button.title", comment: ""), for: .normal)
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
        textField.textColor = .black
        
        let doneBar = DoneBar(textField: textField)
        textField.inputAccessoryView = doneBar
    }

    
}
