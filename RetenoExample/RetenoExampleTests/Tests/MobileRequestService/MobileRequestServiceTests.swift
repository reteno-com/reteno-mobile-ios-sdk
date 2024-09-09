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
        sut.upsertDevice(email: nil, phone: nil, isSubscribedOnPush: true) { result in
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
        sut.upsertDevice(email: nil, phone: nil, isSubscribedOnPush: true) { result in
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
    
    // MARK: - InAppMessage
    
    func test_getInAppMessage_withPositiveResult() {
        let id = "tr66"
        stub(condition: pathEndsWith("v1/inapp/interactions/\(id)/message")) { _ in
            let stubPath = OHPathForFile("in_app_message.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        var expectedModel: InAppMessage?
        let expectation = expectation(description: "Request")
        sut.getInAppMessage(by: id) { result in
            switch result {
            case .success(let model):
                expectedModel = model
                
            case .failure:
                expectedModel = nil
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNotNil(expectedModel, "expected model should exists")
            XCTAssertTrue(expectedModel?.model.isEmpty == false, "model property shouldn't be empty")
        }
    }
    
    func test_getInAppsMessageList_withPositiveResult() {
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        
        var expectedModel: InAppMessageLists?
        let expectation = expectation(description: "Request")
        sut.getInAppMessages(eTag: nil) { result in
            switch result {
            case .success(let result):
                expectedModel = result.list
                
            case .failure:
                expectedModel = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNotNil(expectedModel, "expected model should exists")
            XCTAssertTrue(((expectedModel?.messages.isNotEmpty) != nil), "model property shouldn't be empty")
        }
    }
    
    func test_getInAppsMessageList_withNegativeResult() {
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        var expectedModel: InAppMessageLists?
        let expectation = expectation(description: "Request")
        sut.getInAppMessages(eTag: nil) { result in
            switch result {
            case .success(let result):
                expectedModel = result.list
                
            case .failure:
                expectedModel = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedModel == nil, "expected model shouldn't exists")
        }
    }
    
    func test_getInAppsMessageList_with304Result() {
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 304, headers: nil)
        }
        
        var notModified: Bool = false
        let expectation = expectation(description: "Request")
        sut.getInAppMessages(eTag: nil) { result in
            switch result {
            case .success:
                notModified = false
                
            case .failure(let error):
                notModified = (error as? APIStatusError)?.statusCode == 304
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(notModified, "expected model shouldn't exists")
        }
    }
    
    func test_getInAppsMessageList_withETagHeaderResult() {
        let testEtag = "1234567890"
        stub(condition: pathEndsWith("v1/inapp/messages")) { _ in
            let stubPath = OHPathForFile("in_app_messages.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: ["ETag": testEtag])
        }
        
        var receivedEtag: String?
        let expectation = expectation(description: "Request")
        sut.getInAppMessages(eTag: nil) { result in
            switch result {
            case .success(let result):
                receivedEtag = result.etag
                
            case .failure:
                receivedEtag = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(testEtag == receivedEtag, "tags should be equal")
        }
    }
    
    func test_getInAppsContent_withPositiveResult() {
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubPath = OHPathForFile("in_app_message_content.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        
        var expectedModel: InAppContents?
        let expectation = expectation(description: "Request")
        sut.getInAppMessageContent(messageInstanceIds: [123]) { result in
            switch result {
            case .success(let result):
                expectedModel = result
                
            case .failure:
                expectedModel = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNotNil(expectedModel, "expected model should exists")
        }
    }
    
    func test_getInAppsContent_withNegativeResult() {
        stub(condition: pathEndsWith("v1/inapp/contents/request")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        
        var expectedModel: InAppContents?
        let expectation = expectation(description: "Request")
        sut.getInAppMessageContent(messageInstanceIds: [123]) { result in
            switch result {
            case .success(let result):
                expectedModel = result
                
            case .failure:
                expectedModel = nil
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertNil(expectedModel, "expected model should exists")
        }
    }
    
    func test_sendInteractionWithPositivResult() {
        stub(condition: pathEndsWith("v1/interaction")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 200, headers: nil)
        }
        var expectedSuccess: Bool?
        let expectation = expectation(description: "Request")
        let newInteraction: NewInteraction = .init(
            id: "12312312",
            time: Date(),
            messageInstanceId: 123123123,
            status: .opened,
            statusDescription: nil
        )
        sut.sendInteraction(interaction: newInteraction) { result in
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
    
    func test_sendInteractionWithNegativeResult() {
        stub(condition: pathEndsWith("v1/interaction")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var expectedFailed: Bool?
        let expectation = expectation(description: "Request")
        let newInteraction: NewInteraction = .init(
            id: "12312312",
            time: Date(),
            messageInstanceId: 123123123,
            status: .opened,
            statusDescription: nil
        )
        sut.sendInteraction(interaction: newInteraction) { result in
            switch result {
            case .success:
                expectedFailed = false
                
            case .failure:
                expectedFailed = true
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { _ in
            XCTAssertTrue(expectedFailed ?? false, "expectedFailed should be true")
        }
    }
    
    func test_asyncCheckWithPositivResult() {
        stub(condition: pathEndsWith("v1/inapp/async-rules/check")) { _ in
            let stubPath = OHPathForFile("in_apps_async.json", type(of: self))
            
            return fixture(filePath: stubPath!, headers: nil)
        }
        var checks: [InAppAsyncCheck]?
        let expectation = expectation(description: "Request")
  
        let segmentAsyncIds = [123, 1234, 12345]
        
        sut.checkAsyncSegmentRules(ids: segmentAsyncIds) { result in
            switch result {
            case .success(let success):
                checks = success.checks
                
            case .failure:
                checks = nil
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertNotNil(checks, "checks shouldn't be nil")
            XCTAssertTrue(checks?.count == segmentAsyncIds.count, "count should be equal")
        }
    }
    
    func test_asyncCheckWithNegativeResult() {
        stub(condition: pathEndsWith("v1/inapp/async-rules/check")) { _ in
            let stubData = "OK".data(using: .utf8)
            
            return HTTPStubsResponse(data: stubData!, statusCode: 400, headers: nil)
        }
        var checks: [InAppAsyncCheck]?
        let expectation = expectation(description: "Request")
  
        let segmentAsyncIds = [123, 1234, 12345]
        
        sut.checkAsyncSegmentRules(ids: segmentAsyncIds) { result in
            switch result {
            case .success(let success):
                checks = success.checks
                
            case .failure:
                checks = nil
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0) { _ in
            XCTAssertNil(checks, "checks shouldn't be nil")
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
