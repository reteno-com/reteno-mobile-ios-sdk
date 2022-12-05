//
//  RecomsModel.swift
//  RetenoExample
//
//  Created by Anna Sahaidak on 10.11.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
import Reteno

protocol RecomsModelNavigationHandler {
    
    func openRecomsSettings(_ settings: RecommendationsSettings)
    
}

final class RecomsModel {
    
    private var recoms: [Recommendation] = []
    private var settings: RecommendationsSettings = RecommendationsSettings.defaultSettings()
    
    private let navigationHandler: RecomsModelNavigationHandler
    
    init(navigationHandler: RecomsModelNavigationHandler) {
        self.navigationHandler = navigationHandler
    }
        
    func recomsCount() -> Int {
        recoms.count
    }
    
    func recom(at index: Int) -> Recommendation {
        recoms[index]
    }
    
    func loadRecoms(with settings: RecommendationsSettings, completion: @escaping (Result<Void, Error>) -> Void) {
        self.settings = settings
        Reteno.recommendations().getRecoms(
            recomVariantId: settings.variantId,
            productIds: settings.productsIds,
            categoryId: settings.category,
            filters: settings.filters,
            fields: ["productId", "name", "descr", "imageUrl", "price"]
        ) { [weak self] (result: Result<[Recommendation], Error>)  in
            switch result {
            case .success(let recoms):
                self?.recoms = recoms
                completion(.success(()))
                 
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func openSettings() {
        navigationHandler.openRecomsSettings(settings)
    }
    
    func trackViewedRecom(at index: Int) {
        Reteno.recommendations().logEvent(
            recomVariantId: settings.variantId,
            impressions: [RecomEvent(date: Date(), productId: recoms[index].productId)],
            clicks: []
        )
    }
    
    func trackClickedRecom(at index: Int) {
        Reteno.recommendations().logEvent(
            recomVariantId: settings.variantId,
            impressions: [],
            clicks: [RecomEvent(date: Date(), productId: recoms[index].productId)]
        )
    }
    
}
