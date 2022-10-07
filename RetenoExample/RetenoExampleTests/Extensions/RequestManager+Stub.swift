//
//  RequestManager+Stub.swift
//  RetenoExampleTests
//
//  Created by Anna Sahaidak on 26.09.2022.
//  Copyright © 2022 Yalantis. All rights reserved.
//

import Foundation
@testable import Reteno

extension RequestManager {
    
    static var stub: RequestManager {
        RequestManager(decorators: [], baseURLComponent: "https://test.host/")
    }
    
}
