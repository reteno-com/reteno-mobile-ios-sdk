//
//  EcommerceViewController.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 13.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import UIKit
import SnapKit

final class EcommerceViewController: NiblessViewController {
    
    private let viewModel: EcommerceViewModel
    
    init(viewModel: EcommerceViewModel) {
        self.viewModel = viewModel
        
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("ecommerce_screen.title", comment: "")
        setuplayout()
    }

// MARK: - Actions
    
    @objc
    func productViewed(_ sender: UIButton) {
        viewModel.openProductViewed()
    }
    
    @objc
    func productCategoryViewed(_ sender: UIButton) {
        viewModel.openProductCategoryViewed()
    }
    
    @objc
    func productAddedToWishlist(_ sender: UIButton) {
        viewModel.openProductAddedToWishlist()
    }
    
    @objc
    func cartUpdated(_ sender: UIButton) {
        viewModel.openCartUpdated()
    }
    
    @objc
    func orderCreated(_ sender: UIButton) {
        viewModel.openOrderCreated()
    }
    
    @objc
    func orderUpdated(_ sender: UIButton) {
        viewModel.openOrderUpdated()
    }
    
    @objc
    func orderDelivered(_ sender: UIButton) {
        viewModel.openOrderDelivered()
    }
    
    @objc
    func orderCancelled(_ sender: UIButton) {
        viewModel.openOrderCancelled()
    }
    
    @objc
    func searchRequest(_ sender: UIButton) {
        viewModel.openSearchRequest()
    }
    
}



// MARK: - Layout

private extension EcommerceViewController {
    
    func setuplayout() {
        view.backgroundColor = .white
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12.0
        
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12.0)
            $0.center.equalTo(view.safeAreaLayoutGuide.snp.center)
        }
        
        let productViewedButton = UIButton(type: .system)
        productViewedButton.setTitle(NSLocalizedString("ecommerce_screen.product_viewed_button.title", comment: ""), for: .normal)
        productViewedButton.addTarget(self, action: #selector(productViewed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(productViewedButton)
        baseSetup(for: productViewedButton)
        
        let productCategoryViewedButton = UIButton(type: .system)
        productCategoryViewedButton.setTitle(NSLocalizedString("ecommerce_screen.product_category_viewed_button.title", comment: ""), for: .normal)
        productCategoryViewedButton.addTarget(self, action: #selector(productCategoryViewed(_:)), for: .touchUpInside)
        stack.addArrangedSubview(productCategoryViewedButton)
        baseSetup(for: productCategoryViewedButton)
        
        let productAddedToWishlistButton = UIButton(type: .system)
        productAddedToWishlistButton.setTitle(NSLocalizedString("ecommerce_screen.product_added_to_wishlist_button.title", comment: ""), for: .normal)
        productAddedToWishlistButton.addTarget(self, action: #selector(productAddedToWishlist(_:)), for: .touchUpInside)
        stack.addArrangedSubview(productAddedToWishlistButton)
        baseSetup(for: productAddedToWishlistButton)
        
        let cartUpdatedButton = UIButton(type: .system)
        cartUpdatedButton.setTitle(NSLocalizedString("ecommerce_screen.cart_updated_button.title", comment: ""), for: .normal)
        cartUpdatedButton.addTarget(self, action: #selector(cartUpdated(_:)), for: .touchUpInside)
        stack.addArrangedSubview(cartUpdatedButton)
        baseSetup(for: cartUpdatedButton)
        
        let orderCreatedButton = UIButton(type: .system)
        orderCreatedButton.setTitle(NSLocalizedString("ecommerce_screen.order_created_button.title", comment: ""), for: .normal)
        orderCreatedButton.addTarget(self, action: #selector(orderCreated(_:)), for: .touchUpInside)
        stack.addArrangedSubview(orderCreatedButton)
        baseSetup(for: orderCreatedButton)
        
        let orderUpdatedButton = UIButton(type: .system)
        orderUpdatedButton.setTitle(NSLocalizedString("ecommerce_screen.order_updated_button.title", comment: ""), for: .normal)
        orderUpdatedButton.addTarget(self, action: #selector(orderUpdated(_:)), for: .touchUpInside)
        stack.addArrangedSubview(orderUpdatedButton)
        baseSetup(for: orderUpdatedButton)
        
        let orderDeliveredButton = UIButton(type: .system)
        orderDeliveredButton.setTitle(NSLocalizedString("ecommerce_screen.order_delivered_button.title", comment: ""), for: .normal)
        orderDeliveredButton.addTarget(self, action: #selector(orderDelivered(_:)), for: .touchUpInside)
        stack.addArrangedSubview(orderDeliveredButton)
        baseSetup(for: orderDeliveredButton)
        
        let orderCancelldedButton = UIButton(type: .system)
        orderCancelldedButton.setTitle(NSLocalizedString("ecommerce_screen.order_cancelled_button.title", comment: ""), for: .normal)
        orderCancelldedButton.addTarget(self, action: #selector(orderCancelled(_:)), for: .touchUpInside)
        stack.addArrangedSubview(orderCancelldedButton)
        baseSetup(for: orderCancelldedButton)
        
        let searchRequestButton = UIButton(type: .system)
        searchRequestButton.setTitle(NSLocalizedString("ecommerce_screen.search_request_button.title", comment: ""), for: .normal)
        searchRequestButton.addTarget(self, action: #selector(searchRequest(_:)), for: .touchUpInside)
        stack.addArrangedSubview(searchRequestButton)
        baseSetup(for: searchRequestButton)
        
    }
    
    func baseSetup(for button: UIButton) {
        button.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }
        
        button.backgroundColor = .systemGray
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 6.0
    }
    
}
