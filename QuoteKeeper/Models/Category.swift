import Foundation
import SwiftUI

struct Category: Identifiable, Codable {
    var id = UUID()
    var name: String
    var iconName: String
    var colorName: String
    
    var color: Color {
        switch colorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "orange":
            return .orange
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return .blue
        }
    }
    
    init(name: String, iconName: String = "book.fill", colorName: String = "blue") {
        self.name = name
        self.iconName = iconName
        self.colorName = colorName
    }
}
