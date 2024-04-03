//
//  Ecommerce.swift
//  
//
//  Created by Anna Sahaidak on 28.11.2022.
//

import Foundation

public final class Ecommerce {
    
    public enum EventType {
        case productViewed(product: Product, currencyCode: String?)
        case productCategoryViewed(category: ProductCategory)
        case productAddedToWishlist(product: Product, currencyCode: String?)
        case cartUpdated(cartId: String, products: [ProductInCart], currencyCode: String?)
        case orderCreated(order: Order, currencyCode: String?)
        case orderUpdated(order: Order, currencyCode: String?)
        case orderDelivered(externalOrderId: String)
        case orderCancelled(externalOrderId: String)
        case searchRequest(query: String, isFound: Bool? = nil)
    }
    
    private let requestService: MobileRequestService
    private let scheduler: EventsSenderScheduler
    private let storage: KeyValueStorage
    
    init(
        requestService: MobileRequestService,
        scheduler: EventsSenderScheduler = Reteno.senderScheduler,
        storage: KeyValueStorage
    ) {
        self.requestService = requestService
        self.scheduler = scheduler
        self.storage = storage
    }
    
    /// Log event
    ///
    /// - Parameter type: type of E-commerce event
    /// - Parameter date: Time when event occurred
    /// - Parameter forcePush: indicates if event should be send immediately or in the next scheduled batch
    public func logEvent(type: EventType, date: Date = Date(), forcePush: Bool = false) {
        let event: Event
        switch type {
        case .productViewed(let product, let currencyCode):
            var parameters: [Event.Parameter] = []
            if let productString = product.convertToString() {
                parameters.append(.init(name: "product", value: productString))
            }
            if let currencyCode = currencyCode {
                parameters.append(.init(name: "currencyCode", value: currencyCode))
            }
            event = Event(eventTypeKey: "productViewed", date: date, parameters: parameters)
            
        case .productCategoryViewed(let category):
            var parameters: [Event.Parameter] = []
            if let categoryString = category.convertToString() {
                parameters.append(.init(name: "category", value: categoryString))
            }
            event = Event(eventTypeKey: "productCategoryViewed", date: date, parameters: parameters)
            
        case .productAddedToWishlist(let product, let currencyCode):
            var parameters: [Event.Parameter] = []
            if let productString = product.convertToString() {
                parameters.append(.init(name: "product", value: productString))
            }
            if let currencyCode = currencyCode {
                parameters.append(.init(name: "currencyCode", value: currencyCode))
            }
            event = Event(eventTypeKey: "productAddedToWishlist", date: date, parameters: parameters)
            
        case .cartUpdated(let cartId, let products, let currencyCode):
            var parameters: [Event.Parameter] = [.init(name: "cartId", value: cartId)]
            if let escapedProducts = JSONConverterHelper.convertJSONToString(products.map { $0.toJSON() }) {
                parameters.append(.init(name: "products", value: escapedProducts))
            }
            if let currencyCode = currencyCode {
                parameters.append(.init(name: "currencyCode", value: currencyCode))
            }
            let cartUpdatedEvents = storage.getEvents().filter { $0.isValid && $0.eventTypeKey == "cartUpdated"}
            storage.clearEvents(cartUpdatedEvents)
            event = Event(eventTypeKey: "cartUpdated", date: date, parameters: parameters)
            
        case .orderCreated(let order, let currencyCode):
            var parameters: [Event.Parameter] = order.eventParameters()
            if let currencyCode = currencyCode {
                parameters.append(.init(name: "currencyCode", value: currencyCode))
            }
            event = Event(eventTypeKey: "orderCreated", date: date, parameters: parameters)
            
        case .orderUpdated(let order, let currencyCode):
            var parameters: [Event.Parameter] = order.eventParameters()
            if let currencyCode = currencyCode {
                parameters.append(.init(name: "currencyCode", value: currencyCode))
            }
            event = Event(eventTypeKey: "orderUpdated", date: date, parameters: parameters)
            
        case .orderDelivered(let externalOrderId):
            event = Event(
                eventTypeKey: "orderDelivered",
                date: date,
                parameters: [Event.Parameter(name: "externalOrderId", value: externalOrderId)]
            )
            
        case .orderCancelled(let externalOrderId):
            event = Event(
                eventTypeKey: "orderCancelled",
                date: date,
                parameters: [Event.Parameter(name: "externalOrderId", value: externalOrderId)]
            )
            
        case .searchRequest(let query, let isFound):
            var parameters: [Event.Parameter] = [.init(name: "search", value: query)]
            if let isFound = isFound {
                parameters.append(.init(name: "isFound", value: isFound ? "1" : "0"))
            }
            event = Event(eventTypeKey: "searchRequest", date: date, parameters: parameters)
        }
        storage.addEvent(event)
        
        if forcePush {
            scheduler.forcePushEvents()
        }
    }
    
}
