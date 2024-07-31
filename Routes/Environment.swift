//
//  Environment.swift
//  Routes
//
//  Created by Blake Haug on 7/30/24.
//

import Foundation

public enum EnvironmentVars {
    enum Keys {
        static let googleApiKey = "GOOGLE_API_KEY"
    }
    
    // Get plist file
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    // Get value from plist file
    static let googleApiKey: String = {
        guard let googleApiKey = EnvironmentVars.infoDictionary[Keys.googleApiKey] as? String else {
            fatalError("Google API Key not set in plist for this environment")
        }
        return googleApiKey
    }()
}
