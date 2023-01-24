//
//  EcommerceTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 08.12.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class EcommerceTests: XCTestCase {

    private var requestService: MobileRequestService!
    
    private var userDefaults: UserDefaults!
    private var scheduler: EventsSenderScheduler!
    private var storage: KeyValueStorage!
    private var sut: Ecommerce!
    
    override func setUp() {
        super.setUp()
        
        userDefaults = UserDefaults(suiteName: "unit_tests_operations")
        requestService = MobileRequestService(requestManager: .stub)
        storage = KeyValueStorage(storage: userDefaults)
        storage.clearEventsCache()
        scheduler = buildScheduler()
        sut = Ecommerce(requestService: requestService, scheduler: scheduler, storage: storage)
    }
    
    override func tearDown() {
        super.tearDown()
        
        storage.clearEventsCache()
        requestService = nil
        sut = nil
        userDefaults.removeSuite(named: "unit_tests_operations")
    }
    
    // MARK: productViewed
    
    func test_log_productViewedEvent_withSpecifiedCurrencyCode() throws {
        let product = Ecommerce.Product(
            productId: "jfhfh",
            price: 20,
            isInStock: true
        )
        sut.logEvent(type: .productViewed(product: product, currencyCode: "UAH"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productViewed" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 2, "stored event should have 2 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "product" }),
            "stored event should have product parameter"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"productId\":\"jfhfh\"") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"price\":20") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"isInStock\":1") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event should have currencyCode parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "currencyCode" })?.value,
            "UAH",
            "stored event should have valid currency parameter value"
        )
    }
    
    func test_log_productViewedEvent_withoutCurrencyCode() throws {
        let product = Ecommerce.Product(
            productId: "jfhfh",
            price: 20,
            isInStock: true
        )
        sut.logEvent(type: .productViewed(product: product, currencyCode: nil))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productViewed" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 1, "stored event should have 1 parameter")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "product" }),
            "stored event should have product parameter"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event shouldn't have currencyCode parameter"
        )
    }
    
    // MARK: productCategoryViewed
    
    func test_log_productCategoryViewedEvent() throws {
        let productCategory = Ecommerce.ProductCategory(
            productCategoryId: "ugug",
            attributes: ["size": ["M", "L"]]
        )
        sut.logEvent(type: .productCategoryViewed(category: productCategory))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productCategoryViewed" }.first,
            "stored event model should exists"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "category" }),
            "stored event should have category parameter"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "category" })?.value.contains("\"productCategoryId\":\"ugug\"") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "category" })?.value.contains("\"size\":[\"M\",\"L\"]") == true,
            "stored event should have valid product parameter value"
        )
    }
    
    func test_log_productViewedEvent_withoutAttributes() throws {
        let product = Ecommerce.Product(
            productId: "12312",
            price: 50,
            isInStock: true
        )
        sut.logEvent(type: .productViewed(product: product, currencyCode: "EUR"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productViewed" }.first,
            "stored event model should exists"
        )
    }
    
    // MARK: productAddedToWishlist
    
    func test_log_productAddedToWishlistEvent_withSpecifiedCurrencyCode() throws {
        let product = Ecommerce.Product(
            productId: "jfhfh",
            price: 20,
            isInStock: false
        )
        sut.logEvent(type: .productAddedToWishlist(product: product, currencyCode: "USD"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productAddedToWishlist" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 2, "stored event should have 2 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "product" }),
            "stored event should have product parameter"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"productId\":\"jfhfh\"") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"price\":20") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "product" })?.value.contains("\"isInStock\":0") == true,
            "stored event should have valid product parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event should have currencyCode parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "currencyCode" })?.value,
            "USD",
            "stored event should have valid currency parameter value"
        )
    }
    
    func test_log_productAddedToWishlistEvent_withoutCurrencyCode() throws {
        let product = Ecommerce.Product(
            productId: "jfhfh",
            price: 20,
            isInStock: true
        )
        sut.logEvent(type: .productAddedToWishlist(product: product, currencyCode: nil))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "productAddedToWishlist" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 1, "stored event should have 1 parameter")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "product" }),
            "stored event should have product parameter"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event shouldn't have currencyCode parameter"
        )
    }
    
    // MARK: cartUpdated
    
    func test_log_cartUpdatedEvent_withSpecifiedCurrencyCode() throws {
        let products = [Ecommerce.ProductInCart(productId: "iiu9f", price: 49.0, quantity: 20)]
        sut.logEvent(type: .cartUpdated(cartId: "yfy9", products: products, currencyCode: "EUR"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "cartUpdated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 3, "stored event should have 3 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "cartId" }),
            "stored event should have cartId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "cartId" })?.value,
            "yfy9",
            "stored event should have valid cartId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "products" }),
            "stored event should have products parameter"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "products" })?.value.contains("\"productId\":\"iiu9f\"") == true,
            "stored event should have valid products parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "products" })?.value.contains("\"price\":49") == true,
            "stored event should have valid products parameter value"
        )
        XCTAssertTrue(
            event.parameters.first(where: { $0.name == "products" })?.value.contains("\"quantity\":20") == true,
            "stored event should have valid products parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event should have currencyCode parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "currencyCode" })?.value,
            "EUR",
            "stored event should have valid currency parameter value"
        )
    }
    
    func test_log_cartUpdatedEvent_withoutCurrencyCode() throws {
        let products = [Ecommerce.ProductInCart(productId: "iiu9f", price: 49.0, quantity: 20)]
        sut.logEvent(type: .cartUpdated(cartId: "yfy9", products: products, currencyCode: nil))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "cartUpdated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 2, "stored event should have 2 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "cartId" }),
            "stored event should have cartId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "cartId" })?.value,
            "yfy9",
            "stored event should have valid cartId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "products" }),
            "stored event should have products parameter"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event shouldn't have currencyCode parameter"
        )
    }
    
    // MARK: orderCreated
    
    func test_log_orderCreatedEvent_withSpecifiedCurrencyCode() throws {
        let orderDate = Date()
        let order = Ecommerce.Order(externalOrderId: "fhuf8f", totalCost: 320.0, status: .INITIALIZED, date: orderDate)
        sut.logEvent(type: .orderCreated(order: order, currencyCode: "UAH"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderCreated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 5, "stored event should have 5 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "fhuf8f",
            "stored event should have valid externalOrderId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "totalCost" }),
            "stored event should have totalCost parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "totalCost" })?.value,
            "320.0",
            "stored event should have valid totalCost parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "status" }),
            "stored event should have status parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "status" })?.value,
            "INITIALIZED",
            "stored event should have valid status parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "date" }),
            "stored event should have date parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "date" })?.value,
            DateFormatter.baseBEDateFormatter.string(from: orderDate),
            "stored event should have valid date parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event should have currencyCode parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "currencyCode" })?.value,
            "UAH",
            "stored event should have valid currency parameter value"
        )
    }
    
    func test_log_orderCreatedEvent_withoutCurrencyCode() throws {
        let orderDate = Date()
        let order = Ecommerce.Order(externalOrderId: "fhuf8f", totalCost: 320.0, status: .IN_PROGRESS, date: orderDate)
        sut.logEvent(type: .orderCreated(order: order, currencyCode: nil))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderCreated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 4, "stored event should have 4 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "fhuf8f",
            "stored event should have valid externalOrderId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "totalCost" }),
            "stored event should have totalCost parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "totalCost" })?.value,
            "320.0",
            "stored event should have valid totalCost parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "status" }),
            "stored event should have status parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "status" })?.value,
            "IN_PROGRESS",
            "stored event should have valid status parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "date" }),
            "stored event should have date parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "date" })?.value,
            DateFormatter.baseBEDateFormatter.string(from: orderDate),
            "stored event should have valid date parameter value"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event shouldn't have currencyCode parameter"
        )
    }
    
    // MARK: orderUpdated
    
    func test_log_orderUpdatedEvent_withSpecifiedCurrencyCode() throws {
        let orderDate = Date()
        let order = Ecommerce.Order(externalOrderId: "fhuf8f", totalCost: 320.0, status: .IN_PROGRESS, date: orderDate)
        sut.logEvent(type: .orderUpdated(order: order, currencyCode: "UAH"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderUpdated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 5, "stored event should have 5 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "fhuf8f",
            "stored event should have valid externalOrderId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "totalCost" }),
            "stored event should have totalCost parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "totalCost" })?.value,
            "320.0",
            "stored event should have valid totalCost parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "status" }),
            "stored event should have status parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "status" })?.value,
            "IN_PROGRESS",
            "stored event should have valid status parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "date" }),
            "stored event should have date parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "date" })?.value,
            DateFormatter.baseBEDateFormatter.string(from: orderDate),
            "stored event should have valid date parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event should have currencyCode parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "currencyCode" })?.value,
            "UAH",
            "stored event should have valid currency parameter value"
        )
    }
    
    func test_log_orderUpdatedEvent_withoutCurrencyCode() throws {
        let orderDate = Date()
        let order = Ecommerce.Order(externalOrderId: "fhuf8f", totalCost: 320.0, status: .IN_PROGRESS, date: orderDate)
        sut.logEvent(type: .orderUpdated(order: order, currencyCode: nil))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderUpdated" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 4, "stored event should have 4 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "fhuf8f",
            "stored event should have valid externalOrderId parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "totalCost" }),
            "stored event should have totalCost parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "totalCost" })?.value,
            "320.0",
            "stored event should have valid totalCost parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "status" }),
            "stored event should have status parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "status" })?.value,
            "IN_PROGRESS",
            "stored event should have valid status parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "date" }),
            "stored event should have date parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "date" })?.value,
            DateFormatter.baseBEDateFormatter.string(from: orderDate),
            "stored event should have valid date parameter value"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "currencyCode" }),
            "stored event shouldn't have currencyCode parameter"
        )
    }
    
    // MARK: orderDelivered
    
    func test_log_orderDeliveredEvent() throws {
        sut.logEvent(type: .orderDelivered(externalOrderId: "ifuf7"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderDelivered" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 1, "stored event should have 1 parameter")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "ifuf7",
            "stored event should have valid externalOrderId parameter value"
        )
    }
    
    // MARK: orderCancelled
    
    func test_log_orderCancelledEvent() throws {
        sut.logEvent(type: .orderCancelled(externalOrderId: "ifuf7"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "orderCancelled" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 1, "stored event should have 1 parameter")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "externalOrderId" }),
            "stored event should have externalOrderId parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "externalOrderId" })?.value,
            "ifuf7",
            "stored event should have valid externalOrderId parameter value"
        )
    }
    
    // MARK: searchRequest
    
    func test_log_searchRequestEvent_withIsFoundParameter() throws {
        sut.logEvent(type: .searchRequest(query: "phone", isFound: true))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "searchRequest" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 2, "stored event should have 2 parameters")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "search" }),
            "stored event should have search parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "search" })?.value,
            "phone",
            "stored event should have valid search parameter value"
        )
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "isFound" }),
            "stored event should have isFound parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "isFound" })?.value,
            "1",
            "stored event should have valid isFound parameter value"
        )
    }
    
    func test_log_searchRequestEvent_withoutIsFoundParameter() throws {
        sut.logEvent(type: .searchRequest(query: "phone"))
        let event = try XCTUnwrap(
            storage.getEvents().filter { $0.eventTypeKey == "searchRequest" }.first,
            "stored event model should exists"
        )
        XCTAssertTrue(event.parameters.count == 1, "stored event should have 1 parameter")
        XCTAssertNotNil(
            event.parameters.first(where: { $0.name == "search" }),
            "stored event should have search parameter"
        )
        XCTAssertEqual(
            event.parameters.first(where: { $0.name == "search" })?.value,
            "phone",
            "stored event should have valid search parameter value"
        )
        XCTAssertNil(
            event.parameters.first(where: { $0.name == "isFound" }),
            "stored event shouldn't have isFound parameter"
        )
    }
    
    // MARK: Helpers
    
    private func buildScheduler() -> EventsSenderScheduler {
        let storage = KeyValueStorage(storage: userDefaults)
        let sendingService = SendingServices(requestManager: .stub)
        
        return EventsSenderScheduler(
            mobileRequestService: requestService,
            storage: storage,
            sendingService: sendingService,
            timeIntervalResolver: { 1.0 },
            randomOffsetResolver: { 0.0 }
        )
    }

}
