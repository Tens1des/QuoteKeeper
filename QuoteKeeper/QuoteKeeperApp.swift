//
//  QuoteKeeperApp.swift
//  QuoteKeeper
//
//  Created by Рома Котов on 04.10.2025.
//

import SwiftUI

@main
struct QuoteKeeperApp: App {
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var fontManager = FontManager()
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(themeManager)
                .environmentObject(fontManager)
                .environmentObject(localizationManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
