//
//  SearchRequestModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

final class SearchRequestModel {
    
    private let navigationHandler: EcommerceViewsNavigationHandler
    
    init(navigationHandler: EcommerceViewsNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
    
    func sendEvent(query: String, isFound: Bool?, isForcePushed: Bool) {
        Reteno.ecommerce().logEvent(type: .searchRequest(query: query, isFound: isFound), forcePush: isForcePushed)
    }
    
    func backToEcommerce() {
        navigationHandler.backToEcommerce()
    }
}
