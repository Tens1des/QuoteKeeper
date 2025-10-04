import Foundation

struct Quote: Identifiable, Codable {
    var id = UUID()
    var text: String
    var author: String
    var categories: [String]
    var tags: [String]
    var isFavorite: Bool
    var isPinned: Bool
    var dateAdded: Date
    
    init(text: String, author: String = "", categories: [String] = [], tags: [String] = [], isFavorite: Bool = false, isPinned: Bool = false) {
        self.text = text
        self.author = author
        self.categories = categories
        self.tags = tags
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.dateAdded = Date()
    }
}
