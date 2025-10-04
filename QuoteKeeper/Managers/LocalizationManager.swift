import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: UserProfile.Language
    
    init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = UserProfile.Language(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english // Default to English
        }
        // Don't call setLanguage in init to avoid memory issues
    }
    
    func setLanguage(_ language: UserProfile.Language) {
        self.currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        
        // Set the app's language
        let languageCode = language == .english ? "en" : "ru"
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force UI update immediately
        objectWillChange.send()
    }
}

// Extension to get localized strings
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}

// Singleton for localization
extension LocalizationManager {
    static let shared = LocalizationManager()
    
    func localizedString(for key: String) -> String {
        let languageCode = currentLanguage == .english ? "en" : "ru"
        
        // Load the appropriate strings file
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key // Fallback to key if bundle not found
        }
        
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}
