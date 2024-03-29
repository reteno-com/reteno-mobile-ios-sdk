//
//  SearchRequestViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit

final class SearchRequestViewController: NiblessViewController {
    
    private let stack = UIStackView()
    private let searchQueryTextField = CommonTextField()
    private let isForcePushedLabel = UILabel()
    private let isFoundLabel = UILabel()
    private let isForcePushedSwitch = UISwitch()
    private let isFoundSwitch = UISwitch()
    private let sendEventButton = CommonButton()
    
    private let viewModel: SearchRequestViewModel
    private let reusableViews = ReusableViews()
    
    init(viewModel: SearchRequestViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupHandlers()
    }
    
    @objc
    func sendEvent(_ sender: UIButton) {
        guard let searchQueryText = searchQueryTextField.text, !searchQueryText.isEmpty else { return }
        
        viewModel.sendEvent(query: searchQueryText, isForcePushed: isForcePushedSwitch.isOn, isFound: isFoundSwitch.isOn)
        viewModel.backToEcommerce()
    }
    
    private func setupHandlers() {
        sendEventButton.addTarget(self, action: #selector(sendEvent), for: .touchUpInside)
    }
    
}

// MARK: - Layout

private extension SearchRequestViewController {
    
    func setupLayout() {
        title = NSLocalizedString("ecommerce_screen.search_request_button.title", comment: "")
        view.backgroundColor = .lightGray
        
        let stack = UIStackView()
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20.0)
        }
        stack.axis = .vertical
        stack.spacing = 10.0
        
        stack.addArrangedSubview(searchQueryTextField)
        searchQueryTextField.placeholder = NSLocalizedString("ecommerce_screen.search_request_screen.fields.query", comment: "")
        
        stack.addArrangedSubview(ReusableViews.setupSwitch(
                view: view, label: isFoundLabel,
                switcher: isFoundSwitch,
                labelText: NSLocalizedString( "ecommerce_screen.search_request_screen.labels.is_found_label", comment: "" ),
                switcherIsOn: true)
        )
        
        let isForcedPushOption = ReusableViews.setupSwitch(
            view: view, label: isForcePushedLabel,
            switcher: isForcePushedSwitch,
            labelText: NSLocalizedString("ecommerce_screen.shared.labels.is_force_pushed_label", comment: "")
        )
        view.addSubview(isForcedPushOption)
        isForcedPushOption.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(90.0)
        }
        
        sendEventButton.setTitle(NSLocalizedString("ecommerce_screen.shared.buttons.send_event_button", comment: ""), for: .normal)
        sendEventButton.addTarget(self, action: #selector(sendEvent(_:)), for: .touchUpInside)
        view.addSubview(sendEventButton)
        sendEventButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20.0)
            $0.height.equalTo(50.0)
        }
    }
    
}
