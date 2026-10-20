//
//  AddAccountViewModel.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

final class AddAccountViewModel {
    
    enum ValidationError: LocalizedError {
        case emptyExternalId
        
        var errorDescription: String? {
            NSLocalizedString("addAccount_screen.error.emptyExternalId", comment: "")
        }
    }
    
    private let model: AddAccountModel
    
    init(model: AddAccountModel) {
        self.model = model
    }
    
    func save(_ user: User, accountSuffix: String?) -> Result<Void, ValidationError> {
        guard !user.id.isEmpty else { return .failure(.emptyExternalId) }
        
        model.save(user, accountSuffix: normalized(accountSuffix))
        
        return .success(())
    }
    
    /// Matches what the SDK puts into the device id: no whitespace and no leading `:` separators.
    private func normalized(_ suffix: String?) -> String? {
        var suffix = suffix?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-") ?? ""
        while suffix.hasPrefix(":") {
            suffix.removeFirst()
        }
        
        return suffix.isEmpty ? nil : suffix
    }
    
}
