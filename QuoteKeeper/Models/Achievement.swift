import Foundation

struct Achievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var iconName: String
    var isUnlocked: Bool
    var dateUnlocked: Date?
    var progress: Int
    var goal: Int
    
    init(title: String, description: String, iconName: String, goal: Int, progress: Int = 0, isUnlocked: Bool = false, dateUnlocked: Date? = nil) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isUnlocked = isUnlocked
        self.dateUnlocked = dateUnlocked
        self.progress = progress
        self.goal = goal
    }
}
