import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: UserProfile.Theme = .light
    
    init() {
        // Load theme from UserDefaults
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = UserProfile.Theme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    func setTheme(_ theme: UserProfile.Theme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
        
        // Apply theme to the app
        applyTheme(theme)
    }
    
    private func applyTheme(_ theme: UserProfile.Theme) {
        switch theme {
        case .light:
            // Light theme is default
            break
        case .dark:
            // Dark theme will be applied through color scheme
            break
        case .system:
            // System theme will be applied through color scheme
            break
        }
    }
    
    var colorScheme: ColorScheme? {
        switch currentTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil // Use system default
        }
    }
}
