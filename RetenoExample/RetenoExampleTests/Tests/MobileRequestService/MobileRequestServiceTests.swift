//
//  MobileRequestServiceTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 04.10.2022.
//

import XCTest
import OHHTTPStubs
@testable import Reteno

final class MobileRequestServiceTests: XCTestCase {
    
    private var sut: MobileRequestService!
    
    override func setUp() {
        sut = MobileRequestService(requestManager: RequestManager.stub)
    }
    
    override func tearDown() {
        sut = nil
        HTTPStubs.removeAllStubs()
    }
    
    // MARK: Upsert device
    
    func test_upsertDeviceRequest_withPositiveResult() throws {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.upsertDevice(isSubscribedOnPush: true) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_upsertDeviceRequest_withNegativeResult() throws {
        stub(condition: pathEndsWith("v1/device")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.upsertDevice(isSubscribedOnPush: true) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Update User attributes
    
    func test_updateUserAttributes_withPositiveResult() {
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        let user = User(
            externalUserId: "fjf8",
            userAttributes: UserAttributes(phone: "+380509876755", email: "test@gmail.com", firstName: "john"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: [],
            isAnonymous: false
        )
        sut.updateUserAttributes(user: user) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_updateUserAttributes_withoutExternalUserId() {
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 422, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        let user = User(
            externalUserId: nil,
            userAttributes: UserAttributes(phone: "+380509876755", email: "test@gmail.com", firstName: "john"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: [],
            isAnonymous: false
        )
        sut.updateUserAttributes(user: user) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    func test_updateUserAttributes_withoutExternalUserId_forAnonymousUser() {
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        let user = User(
            externalUserId: nil,
            userAttributes: UserAttributes(firstName: "john"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: [],
            isAnonymous: true
        )
        sut.updateUserAttributes(user: user) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_updateUserAttributes_withoutExternalUserId_forAnonymousUser_withEmail() {
        stub(condition: pathEndsWith("v1/user")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 422, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        let user = User(
            externalUserId: nil,
            userAttributes: UserAttributes(email: "test@gmail.com", firstName: "john"),
            subscriptionKeys: [],
            groupNamesInclude: [],
            groupNamesExclude: [],
            isAnonymous: true
        )
        sut.updateUserAttributes(user: user) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Log events
    
    func test_logEventsRequest_withPositiveResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendEvents([Event(eventTypeKey: "event_key", date: Date(), parameters: [.init(name: "param_name", value: "param_value")])]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_logEventsRequest_withNegativeResult() {
        stub(condition: pathEndsWith("v1/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendEvents([Event(eventTypeKey: "event_key", date: Date(), parameters: [.init(name: "param_name", value: "param_value")])]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Get inbox messages
    
    func test_getInboxMessages_withPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages")) { _ in
            let stubData = "{\"list\":[], \"totalPages\":3}".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        var expectedResponse: AppInboxMessagesResponse?
        let expectation = expectation(description: "Request")
        sut.getInboxMessages(page: nil, pageSize: nil) { result in
            switch result {
            case .success(let response):
                expectedSuccess = true
                expectedResponse = response
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
            XCTAssertEqual(expectedResponse?.totalPages, 3, "expected response totalPages should be 3")
        }
    }
    
    func test_getInboxMessages_withNegativeResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.getInboxMessages(page: nil, pageSize: nil) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Mark inbox message as opened
    
    func test_markInboxMessagesAsOpened_withPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened(ids: []) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_markInboxMessagesAsOpened_withNegativeResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened(ids: []) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Mark all inbox messages as opened
    
    func test_markAllInboxMessagesAsOpened_withPositiveResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_markAllInboxMessagesAsOpened_withNegativeResult() {
        stub(condition: pathEndsWith("v1/appinbox/messages/status")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.markInboxMessagesAsOpened { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Recommendations
    
    func test_getRecoms_withPositiveResult() {
        let variantId = "ygyg7"
        stub(condition: pathEndsWith("v1/recoms/\(variantId)/request")) { [unowned self] _ in
            let stubData = try? self.recomsJsonData()
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        var expectedModels: [Recommendation] = []
        let expectation = expectation(description: "Request")
        sut.getRecoms(
            recomVariantId: variantId,
            productIds: [],
            categoryId: "",
            filters: nil,
            fields: nil
        ) { (result: Result<[Recommendation], Error>) in
            switch result {
            case .success(let recoms):
                expectedSuccess = true
                expectedModels = recoms
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
            XCTAssertEqual(expectedModels.count, 1, "should have 1 item")
            XCTAssertEqual(expectedModels[0].productId, "identificator", "should have valid `productId`")
            XCTAssertEqual(expectedModels[0].products.count, 2, "should have 2 products")
            XCTAssertEqual(expectedModels[0].products[0].name, "Apple", "should have valid `name`")
            XCTAssertEqual(expectedModels[0].products[0].description, "Some text", "should have valid `description`")
            XCTAssertEqual(expectedModels[0].products[0].price, 20.0, "should have valid `price`")
            XCTAssertEqual(expectedModels[0].products[0].count, 5, "should have valid `count`")
            XCTAssertEqual(expectedModels[0].products[1].name, "Potato", "should have valid `name`")
            XCTAssertEqual(expectedModels[0].products[1].description, "Some text", "should have valid `description`")
            XCTAssertEqual(expectedModels[0].products[1].price, 16.0, "should have valid `price`")
            XCTAssertEqual(expectedModels[0].products[1].count, 50, "should have valid `count`")
        }
    }
    
    func test_getRecoms_withNegativeResult() {
        let variantId = "ygyg7"
        stub(condition: pathEndsWith("v1/recoms/\(variantId)/request")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        var expectedModels: [Recommendation] = []
        let expectation = expectation(description: "Request")
        sut.getRecoms(
            recomVariantId: variantId,
            productIds: [],
            categoryId: "",
            filters: nil,
            fields: nil
        ) { (result: Result<[Recommendation], Error>) in
            switch result {
            case .success(let recoms):
                expectedSuccess = true
                expectedModels = recoms
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
            XCTAssertTrue(expectedModels.isEmpty, "should be empty")
        }
    }
    
    func test_logRecomEventsRequest_withPositiveResult() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendRecomEvents([]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedSuccess ?? false, "expectedSuccess should be true")
        }
    }
    
    func test_logRecomEventsRequest_withNegativeResult() {
        stub(condition: pathEndsWith("v1/recoms/events")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        sut.sendRecomEvents([]) { result in
            switch result {
            case .success:
                expectedSuccess = true
                
            case .failure:
                expectedSuccess = false
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertFalse(expectedSuccess ?? true, "expectedSuccess should be false")
        }
    }
    
    // MARK: Helpers
    
    private func recomsJsonData() throws -> Data {
        let json: [String: Any] = [
            "recoms": [
                [
                    "productId": "identificator",
                    "products": [
                        [
                            "name": "Apple",
                            "description": "Some text",
                            "price": 20.0,
                            "count": 5
                        ],
                        [
                            "name": "Potato",
                            "description": "Some text",
                            "price": 16.0,
                            "count": 50
                        ]
                    ]
                ]
            ]
        ]
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
}

private struct Product: Decodable {
    
    let name: String
    let description: String
    let price: Float
    let count: Int
    
}

private struct Recommendation: Decodable, RecommendableProduct {
    
    let productId: String
    let products: [Product]
    
}
