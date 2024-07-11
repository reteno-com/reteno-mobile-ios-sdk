//
//  InAppScriptMessage.swift
//  
//
//  Created by Anna Sahaidak on 20.01.2023.
//

import Foundation

protocol InAppScriptMessagePayload {}

struct InAppScriptMessage: Decodable {
    
    enum MessageType: String {
        case unknown, completedLoading = "WIDGET_INIT_SUCCESS", failedLoading = "WIDGET_INIT_FAILED",
             close = "CLOSE_WIDGET", openURL = "OPEN_URL", click = "CLICK", runtimeError = "WIDGET_RUNTIME_ERROR"
    }
        
    let type: MessageType
    let payload: InAppScriptMessagePayload?
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
    
    init(type: MessageType, payload: InAppScriptMessagePayload? = nil) {
        self.type = type
        self.payload = payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeRawValue = try container.decode(String.self, forKey: .type)
        type = MessageType(rawValue: typeRawValue) ?? .unknown
        
        switch type {
        case .unknown, .close, .completedLoading:
            payload = nil
            
        case .failedLoading, .runtimeError:
            payload = try? container.decode(InAppScriptMessageErrorPayload.self, forKey: .payload)
            
        case .openURL:
            payload = try? container.decode(InAppScriptMessageURLPayload.self, forKey: .payload)
            
        case .click:
            payload = try? container.decode(InAppScriptMessageComponentPayload.self, forKey: .payload)
        }
    }

}

struct InAppScriptMessageURLPayload: Decodable, InAppScriptMessagePayload {
    
    let urlString: String?
    let targetComponentId: String?
    let customData: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case urlString = "url", targetComponentId, customData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.urlString = try? container.decode(String.self, forKey: .urlString)
        self.targetComponentId = try? container.decode(String.self, forKey: .targetComponentId)
        self.customData = try? container.decode([String:Any].self, forKey: .customData)
    }
}

struct InAppScriptMessageErrorPayload: Decodable, InAppScriptMessagePayload {
    
    let reason: String
    
}

struct InAppScriptMessageComponentPayload: Decodable, InAppScriptMessagePayload {
    
    let targetComponentId: String
    
}
