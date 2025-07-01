//
//  CustomDeviceIdViewModel.swift
//  RetenoExample
//
//  Created by George Farafonov on 26.06.2025.
//  Copyright © 2025 Yalantis. All rights reserved.
//

import Foundation

final class CustomDeviceIdViewModel {
    
    private let model: CustomDeviceIdModel
    
    init(model: CustomDeviceIdModel) {
        self.model = model
    }
    
    func generateId() -> String {
        model.generateId()
    }
    
    func updateIsCustomDeviceId(isCustomDeviceId: Bool) {
        model.updateIsCustomToggle(isCustomDeviceId)
    }
    
    func getDeviceId() -> String? {
        model.getDeviceId()
    }
    
    func isCustomDeviceId() -> Bool {
        model.isCustomDeviceId()
    }
    
    func save(deviceId: String) {
        model.save(deviceId: deviceId)
    }
}
