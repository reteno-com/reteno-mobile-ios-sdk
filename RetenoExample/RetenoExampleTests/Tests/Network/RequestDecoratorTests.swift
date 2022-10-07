//
//  RequestDecoratorTests.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 23.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import XCTest
import Alamofire
@testable import Reteno

final class RequestDecoratorTests: XCTestCase {

    func test_decoratedRequest() {
        var request: APIRequest = ApiRequestMock(path: "some_path")
        let contentTypeDecorator = RequestDecorator { request in
            request.headers?.add(name: "Content-Type", value: "application/json")
        }
        contentTypeDecorator.decorate(&request)
        XCTAssertTrue(
            request.headers?.contains(where: { $0.name == "Content-Type" && $0.value == "application/json" }) != nil,
            "should have valid header"
        )
    }

}
