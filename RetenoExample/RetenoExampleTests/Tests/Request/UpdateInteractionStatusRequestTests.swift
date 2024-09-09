//
//  UpdateInteractionStatusRequestTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 27.09.2022.
//

import XCTest
@testable import Reteno

final class UpdateInteractionStatusRequestTests: XCTestCase {
    
    // MARK: Delivered status
    
    func test_createRequest_withIdStatusDeliveredAndDate() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.delivered
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(interactionId: id, status: status, date: Date())
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
    }
    
    func test_createRequest_withIdStatusDeliveredDateToken() throws {
        let id = "sakdsakldsjkdsldjkls"
        let token = "sskvkdnvkldsmsvkklnvxkxcvkxnlvcknlv"
        let status = InteractionStatus.delivered
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(interactionId: id, status: status, date: Date()),
            token: token
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        
        let stringToken = try XCTUnwrap(parameters["token"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringToken, token, "token should be equal to \(token)")
        
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
    }
    
    // MARK: Clicked status
    
    func test_createRequest_withIdStatusClickedAndDate() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(interactionId: id, status: status, date: Date())
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
    }
    
    func test_createRequest_withIdStatusClickedDateToken() throws {
        let id = "sakdsakldsjkdsldjkls"
        let token = "sskvkdnvkldsmsvkklnvxkxcvkxnlvcknlv"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(interactionId: id, status: status, date: Date()),
            token: token
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        
        let stringToken = try XCTUnwrap(parameters["token"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringToken, token, "token should be equal to \(token)")
        
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
    }
    
    func test_createRequest_withIdStatusClickedDateToken_andAction() throws {
        let id = "sakdsakldsjkdsldjkls"
        let token = "sskvkdnvkldsmsvkklnvxkxcvkxnlvcknlv"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(
                interactionId: id,
                status: status,
                date: Date(),
                action: .init(type: "CLICKED", targetComponentId: "23")
            ),
            token: token
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        
        let stringToken = try XCTUnwrap(parameters["token"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringToken, token, "token should be equal to \(token)")
        
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
        
        let action = try XCTUnwrap(parameters["action"] as? [String: Any], "action parameter shouldn't be nil")
        let actionType = try XCTUnwrap(action["type"] as? String, "action type parameter shouldn't be nil")
        XCTAssertEqual(actionType, "CLICKED", "actionType should have valid value")
        let targetComponentId = try XCTUnwrap(action["targetComponentId"] as? String, "targetComponentId parameter shouldn't be nil")
        XCTAssertEqual(targetComponentId, "23", "targetComponentId should have valid value")
    }
    
    func test_createRequest_withIdStatusClickedDateToken_andAction_withURL() throws {
        let id = "sakdsakldsjkdsldjkls"
        let token = "sskvkdnvkldsmsvkklnvxkxcvkxnlvcknlv"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(
            status: NotificationStatus(
                interactionId: id,
                status: status,
                date: Date(),
                action: .init(type: "OPEN_URL", targetComponentId: "23", url: "www.google.com")
            ),
            token: token
        )
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status should be equal to \(status.rawValue)")
        
        let stringToken = try XCTUnwrap(parameters["token"] as? String, "status parameter shouldn't be nil")
        XCTAssertEqual(stringToken, token, "token should be equal to \(token)")
        
        XCTAssertNotNil(request.parameters?["time"], "time shouldn't be nil")
        
        let action = try XCTUnwrap(parameters["action"] as? [String: Any], "action parameter shouldn't be nil")
        let actionType = try XCTUnwrap(action["type"] as? String, "action type parameter shouldn't be nil")
        XCTAssertEqual(actionType, "OPEN_URL", "actionType should have valid value")
        let targetComponentId = try XCTUnwrap(action["targetComponentId"] as? String, "targetComponentId parameter shouldn't be nil")
        XCTAssertEqual(targetComponentId, "23", "targetComponentId should have valid value")
        let url = try XCTUnwrap(action["url"] as? String, "url parameter shouldn't be nil")
        XCTAssertEqual(url, "www.google.com", "url should have valid value")
    }
    
}
