import Foundation
import SwiftUI
import Combine

class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var categories: [Category] = []
    @Published var achievements: [Achievement] = []
    @Published var userProfile: UserProfile = UserProfile()
    
    private let quotesKey = "quotes"
    private let categoriesKey = "categories"
    private let achievementsKey = "achievements"
    private let userProfileKey = "userProfile"
    
    init() {
        // Load data asynchronously to avoid memory issues
        DispatchQueue.main.async {
            self.loadData()
            self.setupDefaultData()
        }
    }
    
    // MARK: - Data Loading and Saving
    
    private func loadData() {
        quotes = loadFromUserDefaults(forKey: quotesKey) ?? []
        categories = loadFromUserDefaults(forKey: categoriesKey) ?? []
        achievements = loadFromUserDefaults(forKey: achievementsKey) ?? []
        userProfile = loadFromUserDefaults(forKey: userProfileKey) ?? UserProfile()
    }
    
    private func saveData() {
        saveToUserDefaults(data: quotes, forKey: quotesKey)
        saveToUserDefaults(data: categories, forKey: categoriesKey)
        saveToUserDefaults(data: achievements, forKey: achievementsKey)
        saveToUserDefaults(data: userProfile, forKey: userProfileKey)
    }
    
    private func loadFromUserDefaults<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func saveToUserDefaults<T: Codable>(data: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // MARK: - Default Data Setup
    
    private func setupDefaultData() {
        // Setup default categories
        if categories.isEmpty {
            setupDefaultCategories()
        }

        // Provide locked achievements by default so users can see goals
        if achievements.isEmpty {
            setupDefaultAchievements()
        }
        
        // Do not create default quotes – user starts with an empty library
        saveData()
    }
    
    private func setupDefaultCategories() {
        categories = [
            Category(name: "Life", iconName: "heart.fill", colorName: "blue"),
            Category(name: "Work", iconName: "briefcase.fill", colorName: "green"),
            Category(name: "Motivation", iconName: "star.fill", colorName: "pink"),
            Category(name: "Wisdom", iconName: "lightbulb.fill", colorName: "purple"),
            Category(name: "Growth", iconName: "chart.line.uptrend.xyaxis", colorName: "orange"),
            Category(name: "Books", iconName: "book.fill", colorName: "blue"),
            Category(name: "Humor", iconName: "face.smiling.fill", colorName: "yellow"),
            Category(name: "Dreams", iconName: "moon.stars.fill", colorName: "red")
        ]
    }
    
    // Removed setupDefaultQuotes - user starts with empty quotes
    
    private func setupDefaultAchievements() {
        achievements = createDefaultAchievements()
    }
    
    // MARK: - Quote Management
    
    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveData()
        checkAchievements()
    }
    
    func updateQuote(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote
            saveData()
        }
    }
    
    func deleteQuote(_ quote: Quote) {
        quotes.removeAll { $0.id == quote.id }
        saveData()
    }
    
    func toggleFavorite(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveData()
        }
    }
    
    func togglePin(_ quote: Quote) {
        // First unpin any currently pinned quote
        if !quote.isPinned {
            for i in 0..<quotes.count {
                if quotes[i].isPinned {
                    quotes[i].isPinned = false
                }
            }
        }
        
        // Then pin/unpin the selected quote
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isPinned.toggle()
            saveData()
        }
    }
    
    // MARK: - Category Management
    
    func addCategory(_ category: Category) {
        categories.append(category)
        saveData()
    }
    
    func updateCategory(_ category: Category) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveData()
        }
    }
    
    func deleteCategory(_ category: Category) {
        // Remove category from all quotes
        for i in 0..<quotes.count {
            quotes[i].categories.removeAll { $0 == category.name }
        }
        
        // Remove the category itself
        categories.removeAll { $0.id == category.id }
        saveData()
    }
    
    // MARK: - User Profile Management
    
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
    }
    
    // MARK: - Data Reset (for testing)
    
    func resetAllData() {
        quotes = []
        achievements = createDefaultAchievements()
        userProfile = UserProfile()
        saveData()
    }
    
    private func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(
                title: "First Steps",
                description: "Add your first quote to the collection",
                iconName: "pencil",
                goal: 1,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Collector",
                description: "Save 50 quotes to your library",
                iconName: "books.vertical.fill",
                goal: 50,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Wisdom Keeper",
                description: "Reach 200 saved quotes",
                iconName: "text.quote",
                goal: 200,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Favorite Mark",
                description: "Mark a quote as favorite",
                iconName: "star.fill",
                goal: 1,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Random Explorer",
                description: "Use Random 10 times",
                iconName: "bolt.fill",
                goal: 10,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Organizer",
                description: "Create 5 categories",
                iconName: "square.grid.2x2",
                goal: 5,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Tag Master",
                description: "Add tags to 20 quotes",
                iconName: "tag.fill",
                goal: 20,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Nostalgia",
                description: "Browse quotes by recent additions",
                iconName: "clock",
                goal: 1,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Style Setter",
                description: "Change theme or text size",
                iconName: "paintbrush.fill",
                goal: 1,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Pinned Gem",
                description: "Pin a favorite quote",
                iconName: "pin.fill",
                goal: 1,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Week Warrior",
                description: "Add quotes for 7 days in a row",
                iconName: "calendar",
                goal: 7,
                progress: 0,
                isUnlocked: false
            ),
            Achievement(
                title: "Daily Opener",
                description: "Open the app on 10 different days",
                iconName: "sun.max.fill",
                goal: 10,
                progress: 0,
                isUnlocked: false
            )
        ]
    }
    
    // MARK: - Filtered Quote Access
    
    var pinnedQuote: Quote? {
        quotes.first { $0.isPinned }
    }
    
    var favoriteQuotes: [Quote] {
        quotes.filter { $0.isFavorite }.sorted(by: { $0.dateAdded > $1.dateAdded })
    }
    
    func quotesByCategory(_ category: String) -> [Quote] {
        quotes.filter { $0.categories.contains(category) }
    }
    
    func quotesByTag(_ tag: String) -> [Quote] {
        quotes.filter { $0.tags.contains(tag) }
    }
    
    func randomQuote() -> Quote? {
        guard !quotes.isEmpty else { return nil }
        return quotes.randomElement()
    }
    
    // MARK: - Statistics
    
    var totalQuotesCount: Int {
        quotes.count
    }
    
    var favoritesCount: Int {
        quotes.filter { $0.isFavorite }.count
    }
    
    var categoriesCount: Int {
        categories.count
    }
    
    var thisMonthQuotesCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        return quotes.filter { $0.dateAdded >= startOfMonth }.count
    }
    
    // MARK: - Achievements
    
    private func checkAchievements() {
        // First Steps
        if let achievement = achievements.first(where: { $0.title == "First Steps" }), !achievement.isUnlocked {
            if quotes.count >= 1 {
                updateAchievement(achievement, progress: 1, isUnlocked: true)
            }
        }
        
        // Century Club
        if let achievement = achievements.first(where: { $0.title == "Century Club" }), !achievement.isUnlocked {
            let progress = min(quotes.count, 100)
            if progress >= 100 {
                updateAchievement(achievement, progress: progress, isUnlocked: true)
            } else {
                updateAchievement(achievement, progress: progress, isUnlocked: false)
            }
        }
        
        // Diversity Master
        if let achievement = achievements.first(where: { $0.title == "Diversity Master" }), !achievement.isUnlocked {
            let uniqueCategories = Set(quotes.flatMap { $0.categories })
            let progress = min(uniqueCategories.count, 10)
            if progress >= 10 {
                updateAchievement(achievement, progress: progress, isUnlocked: true)
            } else {
                updateAchievement(achievement, progress: progress, isUnlocked: false)
            }
        }
    }
    
    private func updateAchievement(_ achievement: Achievement, progress: Int, isUnlocked: Bool) {
        if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
            achievements[index].progress = progress
            
            if isUnlocked && !achievements[index].isUnlocked {
                achievements[index].isUnlocked = true
                achievements[index].dateUnlocked = Date()
            }
            
            saveData()
        }
    }
}
