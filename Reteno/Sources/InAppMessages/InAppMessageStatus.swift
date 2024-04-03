//
//  InAppMessageStatus.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 25.03.2024.
//

import Foundation

public enum InAppMessageStatus {
    case inAppShouldBeDisplayed
    case inAppIsDisplayed
    case inAppShouldBeClosed(action: InAppMessageAction)
    case inAppIsClosed(action: InAppMessageAction)
    case inAppReceivedError(error: String)
}

public struct InAppMessageAction {
    public let isCloseButtonClicked: Bool
    public let isButtonClicked: Bool
    public let isOpenUrlClicked: Bool
    
    init(
        isCloseButtonClicked: Bool = false,
        isButtonClicked: Bool = false,
        isOpenUrlClicked: Bool = false
    ) {
        self.isCloseButtonClicked = isCloseButtonClicked
        self.isButtonClicked = isButtonClicked
        self.isOpenUrlClicked = isOpenUrlClicked
    }
}
