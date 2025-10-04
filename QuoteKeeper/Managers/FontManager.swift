import SwiftUI

class FontManager: ObservableObject {
    @Published var currentTextSize: UserProfile.TextSize = .standard
    
    init() {
        // Load text size from UserDefaults
        if let savedTextSize = UserDefaults.standard.string(forKey: "selectedTextSize"),
           let textSize = UserProfile.TextSize(rawValue: savedTextSize) {
            currentTextSize = textSize
        }
    }
    
    func setTextSize(_ textSize: UserProfile.TextSize) {
        currentTextSize = textSize
        UserDefaults.standard.set(textSize.rawValue, forKey: "selectedTextSize")
    }
    
    // MARK: - Font Sizes
    
    var bodyFont: Font {
        switch currentTextSize {
        case .small:
            return .caption
        case .standard:
            return .body
        case .large:
            return .title3
        }
    }
    
    var titleFont: Font {
        switch currentTextSize {
        case .small:
            return .subheadline
        case .standard:
            return .title3
        case .large:
            return .title2
        }
    }
    
    var headlineFont: Font {
        switch currentTextSize {
        case .small:
            return .headline
        case .standard:
            return .title2
        case .large:
            return .title
        }
    }
    
    var captionFont: Font {
        switch currentTextSize {
        case .small:
            return .caption2
        case .standard:
            return .caption
        case .large:
            return .subheadline
        }
    }
}
