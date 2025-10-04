import Foundation
import SwiftUI

struct UserProfile: Codable {
    var name: String
    var email: String
    var avatarIconName: String
    var language: Language
    var theme: Theme
    var textSize: TextSize
    
    init(name: String = "", email: String = "", avatarIconName: String = "person.fill", 
         language: Language = .english, theme: Theme = .light, 
         textSize: TextSize = .standard) {
        self.name = name
        self.email = email
        self.avatarIconName = avatarIconName
        self.language = language
        self.theme = theme
        self.textSize = textSize
    }
    
    enum Language: String, Codable, CaseIterable {
        case english = "English"
        case russian = "Russian"
    }
    
    enum Theme: String, Codable, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    enum TextSize: String, Codable, CaseIterable {
        case small = "Small"
        case standard = "Standard"
        case large = "Large"
    }
    
    // MARK: - Computed Properties for UI
    
    var fontSize: Font {
        switch textSize {
        case .small:
            return .caption
        case .standard:
            return .body
        case .large:
            return .title3
        }
    }
    
    var titleFontSize: Font {
        switch textSize {
        case .small:
            return .subheadline
        case .standard:
            return .title3
        case .large:
            return .title2
        }
    }
}
