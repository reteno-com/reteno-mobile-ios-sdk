//
//  ProfileStorage.swift
//  RetenoExample
//
//  Copyright © 2026 Yalantis. All rights reserved.
//

import Foundation

/// The profile last sent from the "Create profile" screen.
struct StoredProfile: Codable, Equatable {
    
    var user: User
    var isAnonymous: Bool
    var isMarketingPushEnabled: Bool
    
}

/// Example-app side copy of the single-account profile. The SDK doesn't expose the attributes it has sent.
enum ProfileStorage {
    
    private static let profileKey = "Profile.StoredProfile"
    
    static var profile: StoredProfile? {
        get {
            guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
            
            return try? JSONDecoder().decode(StoredProfile.self, from: data)
        }
        set {
            guard let newValue, let data = try? JSONEncoder().encode(newValue) else {
                UserDefaults.standard.removeObject(forKey: profileKey)
                return
            }
            
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
}
