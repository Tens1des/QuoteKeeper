import SwiftUI

struct FilterChipsView: View {
    @Binding var selectedCategory: String?
    let categories: [Category]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .black
                ) {
                    selectedCategory = nil
                }
                
                ForEach(categories) { category in
                    FilterChip(
                        title: category.name,
                        isSelected: selectedCategory == category.name,
                        color: category.color
                    ) {
                        selectedCategory = category.name
                    }
                }
                
                // More categories button
                if categories.count > 5 {
                    Button(action: {
                        // Action to show all categories
                    }) {
                        Image(systemName: "square.grid.2x2.fill")
                            .foregroundColor(.purple)
                            .padding(8)
                            .background(Color.purple.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct FilterChipsView_Previews: PreviewProvider {
    static var previews: some View {
        let categories = [
            Category(name: "Life", iconName: "heart.fill", colorName: "blue"),
            Category(name: "Work", iconName: "briefcase.fill", colorName: "green"),
            Category(name: "Motivation", iconName: "star.fill", colorName: "pink")
        ]
        
        return FilterChipsView(selectedCategory: .constant(nil), categories: categories)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
