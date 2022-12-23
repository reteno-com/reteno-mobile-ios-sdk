//
//  SearchRequestViewModel.swift
//  RetenoExample
//
//  Created by Serhii Nikolaiev on 17.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class SearchRequestViewModel {
    
    private let model: SearchRequestModel
    
    init(model: SearchRequestModel) {
        self.model = model
    }
    
    func sendEvent(query: String, isForcePushed: Bool, isFound: Bool?) {
        model.sendEvent(query: query, isFound: isFound, isForcePushed: isForcePushed)
    }
    
    func backToEcommerce() {
        model.backToEcommerce()
    }
    
}
