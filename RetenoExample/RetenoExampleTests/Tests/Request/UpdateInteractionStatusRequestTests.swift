//
//  UpdateInteractionStatusRequestTests.swift
//  RetenoExampleTests
//
//  Created by Serhii Prykhodko on 27.09.2022.
//

import XCTest
import Alamofire
@testable import Reteno

final class UpdateInteractionStatusRequestTests: XCTestCase {
    
    // MARK: Delivered status
    
    func test_createRequest_withIdAndStatusDelivered() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.delivered
        let request = UpdateInteractionStatusRequest(interactionId: id, status: status)
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldnt be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status shoud be equal to \(status.rawValue)")
        XCTAssertNil(request.parameters?["time"], "time should be nill")
    }
    
    func test_createRequest_withIdStatusDeliveredAndDate() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.delivered
        let request = UpdateInteractionStatusRequest(interactionId: id, status: status, time: Date())
        
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
        let request = UpdateInteractionStatusRequest(interactionId: id, token: token, status: status, time: Date())
        
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
    
    func test_createRequest_withIdAndStatusClicked() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(interactionId: id, status: status)
        
        XCTAssertEqual(
            "v1/interactions/\(id)/status",
            request.path,
            "request.path should be equal to v1/interactions/\(id)/status"
        )
        
        let parameters = try XCTUnwrap(request.parameters, "request.parameters shouldnt be nil")
        let stringStatus = try XCTUnwrap(parameters["status"] as? String, "status parameter shouldnt be nil")
        XCTAssertEqual(stringStatus, status.rawValue, "status shoud be equal to \(status.rawValue)")
        XCTAssertNil(request.parameters?["time"], "time should be nill")
    }
    
    func test_createRequest_withIdStatusClickedAndDate() throws {
        let id = "sakdsakldsjkdsldjkls"
        let status = InteractionStatus.clicked
        let request = UpdateInteractionStatusRequest(interactionId: id, status: status, time: Date())
        
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
        let request = UpdateInteractionStatusRequest(interactionId: id, token: token, status: status, time: Date())
        
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
    
}
