//
//  InAppContents.swift
//  Reteno
//
//  Created by Oleh Mytsovda on 29.01.2024.
//

import Foundation

struct InAppContents: Decodable {
    
    let contents: [InAppContent]
    
}

struct InAppContent: InApp {
    var id: String { isWorkflow ? iid ?? String(messageInstanceId) : String(messageInstanceId) }
    
    let messageInstanceId: Int
    let layoutType: LayoutType
    let layoutParams: LayoutParams?
    let model: String
    let iid: String?
    let personalisation: String?
    var inWorkflow: Bool? = nil
    var expiresAt: String? = nil
    var workflowContext: String? = nil
    var workflowRules: Data? = nil

    var isWorkflow: Bool { inWorkflow == true }
    func isAvailable(at date: Date) -> Bool {
        guard isWorkflow else { return true }
        guard let iid, UUID(uuidString: iid) != nil, let expiresAt,
              let deadline = WorkflowDate.parse(expiresAt) else { return false }
        return date < deadline
    }
    
    enum CodingKeys: String, CodingKey {
        case messageInstanceId, layoutType, model, layoutParams, iid, personalisation, inWorkflow, expiresAt, workflowContext
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.messageInstanceId = try container.decode(Int.self, forKey: .messageInstanceId)
        self.iid = try container.decodeIfPresent(String.self, forKey: .iid)
        self.inWorkflow = try container.decodeIfPresent(Bool.self, forKey: .inWorkflow)
        self.expiresAt = try container.decodeIfPresent(String.self, forKey: .expiresAt)
        self.workflowContext = try container.decodeIfPresent(String.self, forKey: .workflowContext)
        if let payload = try? container.decode([String: Any].self, forKey: .personalisation) {
            self.personalisation = String(data: try JSONSerialization.data(withJSONObject: payload), encoding: .utf8)
        } else {
            self.personalisation = nil
        }
        self.layoutType = LayoutType(rawValue: try container.decode(String.self, forKey: .layoutType)) ?? .full
        self.layoutParams = try? container.decodeIfPresent(LayoutParams.self, forKey: .layoutParams)
        
        let modelPayload = try container.decode([String: Any].self, forKey: .model)
        let modelData = try JSONSerialization.data(withJSONObject: modelPayload)
        self.model = String(data: modelData, encoding: .utf8) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageInstanceId, forKey: .messageInstanceId)
        try container.encodeIfPresent(iid, forKey: .iid)
        try container.encodeIfPresent(inWorkflow, forKey: .inWorkflow)
        try container.encodeIfPresent(expiresAt, forKey: .expiresAt)
        try container.encodeIfPresent(workflowContext, forKey: .workflowContext)
        if let data = personalisation?.data(using: .utf8) {
            try container.encode(try JSONSerialization.jsonObject(with: data) as? [String: Any], forKey: .personalisation)
        }
        try container.encode(self.layoutType, forKey: .layoutType)
        try container.encodeIfPresent(self.layoutParams, forKey: .layoutParams)
        
        if let data = self.model.data(using: .utf8) {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            try container.encode(json, forKey: .model)
        }
    }
    
}
