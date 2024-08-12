//
//  RecommendationsService.swift
//  
//
//  Created by Anna Sahaidak on 09.11.2022.
//

import UIKit

public final class Recommendations {
    
    private let requestService: MobileRequestService
    private let scheduler: EventsSenderScheduler
    private let storage: KeyValueStorage
    
    init(
        requestService: MobileRequestService,
        storage: KeyValueStorage,
        scheduler: EventsSenderScheduler = Reteno.senderScheduler
    ) {
        self.requestService = requestService
        self.scheduler = scheduler
        self.storage = storage
    }
    
    /// Get product recommendations
    ///
    /// - Parameter recomVariantId: recommendations variant identificator
    /// - Parameter productIds: product IDs for product-based algorithms
    /// - Parameter categoryId: product category ID for category-based algorithms
    /// - Parameter filters: additional algorithm filters array
    /// - Parameter fields: response model fields keys
    public func getRecoms<T: RecommendableProduct>(
        recomVariantId: String,
        productIds: [String],
        categoryId: String?,
        filters: [RecomFilter]?,
        fields: [String]?,
        completionHandler: @escaping (Result<[T], Error>) -> Void
    ) {
        requestService.getRecoms(
            recomVariantId: recomVariantId,
            productIds: productIds,
            categoryId: categoryId,
            filters: filters,
            fields: fields,
            completionHandler: completionHandler
        )
    }
    
    /// Log recommendation event
    ///
    /// - Parameter recomVariantId: recommendation identificator
    /// - Parameter impressions: events describing that a specific product recommendation was shown to a user
    /// - Parameter clicks: events describing that a user clicked a specific product recommendation
    /// - Parameter forcePush: indicates if event should be send immediately or in the next scheduled batch.
    public func logEvent(recomVariantId: String, impressions: [RecomEvent], clicks: [RecomEvent], forcePush: Bool = false) {
        let recomEvents = RecomEvents(recomVariantId: recomVariantId, impressions: impressions, clicks: clicks)
        storage.addRecomEvent(recomEvents)
        if forcePush {
            scheduler.forcePushEvents()
        }
    }

}
