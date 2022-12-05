//
//  RecomsViewModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 10.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation

final class RecomsViewModel {
    
    private let model: RecomsModel
    
    init(model: RecomsModel) {
        self.model = model
    }
    
    func recomsCount() -> Int {
        model.recomsCount()
    }
    
    func recoms(at index: Int) -> Recommendation {
        model.recom(at: index)
    }
    
    func loadRecoms(with settings: RecommendationsSettings, completion: @escaping (Result<Void, Error>) -> Void) {
        model.loadRecoms(with: settings, completion: completion)
    }
    
    func openSettings() {
        model.openSettings()
    }
    
    func trackViewedRecom(at index: Int) {
        model.trackViewedRecom(at: index)
    }
    
    func trackClickedRecom(at index: Int) {
        model.trackClickedRecom(at: index)
    }
    
}
