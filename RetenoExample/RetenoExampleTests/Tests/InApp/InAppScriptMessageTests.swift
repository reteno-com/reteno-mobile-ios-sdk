//
//  InAppScriptMessageTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 31.01.2023.
//  Copyright © 2023 Yalantis. All rights reserved.
//

import XCTest
@testable import Reteno

final class InAppScriptMessageTests: XCTestCase {

    private var sut: InAppScriptMessage!
    
    func test_initialization_for_completedLoadingModelType() throws {
        let jsonString = "{\"type\":\"WIDGET_INIT_SUCCESS\",\"payload\":{}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .completedLoading, "model should have valid type")
        XCTAssertNil(result.payload, "model with such type shouldn't have payload")
    }
    
    func test_initialization_for_closeModelType() throws {
        let jsonString = "{\"type\":\"CLOSE_WIDGET\",\"payload\":{}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .close, "model should have valid type")
        XCTAssertNil(result.payload, "model with such type shouldn't have payload")
    }
    
    func test_initialization_for_failedLoadingModelType() throws {
        let jsonString = "{\"type\":\"WIDGET_INIT_FAILED\",\"payload\":{\"reason\":\"ReferenceError documentModel is not defined\",\"targetComponentId\":\"id6\"}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .failedLoading, "model should have valid type")
        XCTAssertTrue(result.payload is InAppScriptMessageErrorPayload, "model should have payload type")
    }
    
    func test_initialization_for_runtimeErrorModelType() throws {
        let jsonString = "{\"type\":\"WIDGET_RUNTIME_ERROR\",\"payload\":{\"reason\":\"ReferenceError documentModel is not defined\",\"targetComponentId\":\"id6\"}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .runtimeError, "model should have valid type")
        XCTAssertTrue(result.payload is InAppScriptMessageErrorPayload, "model should have payload type")
    }
    
    func test_initialization_for_openURLModelType_withURL() throws {
        let jsonString = "{\"type\":\"OPEN_URL\",\"payload\":{\"url\":\"https://google.com\",\"targetComponentId\":\"id4\"}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .openURL, "model should have valid type")
        XCTAssertTrue(result.payload is InAppScriptMessageURLPayload, "model should have payload type")
    }
    
    func test_initialization_for_openURLModelType_withDeeplink() throws {
        let jsonString = "{\"type\":\"OPEN_URL\",\"payload\":{\"url\":\"example-app:showProfile\",\"targetComponentId\":\"id5\"}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .openURL, "model should have valid type")
        XCTAssertTrue(result.payload is InAppScriptMessageURLPayload, "model should have payload type")
    }
    
    func test_initialization_for_unknownModelType() throws {
        let jsonString = "{\"type\":\"\",\"payload\":{\"reason\":\"ReferenceError documentModel is not defined\",\"targetComponentId\":\"id6\"}}"
        let result = try XCTUnwrap(createModel(from: jsonString), "models shouldn't be nil")
        
        XCTAssertEqual(result.type, .unknown, "model should have valid type")
        XCTAssertNil(result.payload, "model with such type shouldn't have payload")
    }
    
    // MARK: Helpers
    
    private func createModel(from jsonString: String) -> InAppScriptMessage? {
        do {
            guard let jsonData = jsonString.data(using: .utf8) else { return nil }
            
            return try JSONDecoder().decode(InAppScriptMessage.self, from: jsonData)
        } catch {
            return nil
        }
    }

}
