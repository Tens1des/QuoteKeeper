import SwiftUI

struct QuoteCardView: View {
    @State private var quote: Quote
    let viewModel: QuoteViewModel
    @EnvironmentObject var fontManager: FontManager
    var showFullContent: Bool = false
    var onTap: () -> Void
    
    init(quote: Quote, viewModel: QuoteViewModel, showFullContent: Bool = false, onTap: @escaping () -> Void) {
        self._quote = State(initialValue: quote)
        self.viewModel = viewModel
        self.showFullContent = showFullContent
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote content
            VStack(alignment: .leading, spacing: 8) {
                if showFullContent {
                    // Quote marks for detailed view
                    HStack {
                        Text("❝")
                            .font(.system(size: 40))
                            .foregroundColor(.pink.opacity(0.5))
                        Spacer()
                    }
                }
                
                Text(quote.text)
                    .font(showFullContent ? fontManager.titleFont : fontManager.bodyFont)
                    .lineLimit(showFullContent ? nil : 2)
                    .padding(.horizontal, showFullContent ? 8 : 0)
                
                if !quote.author.isEmpty {
                    Text("— \(quote.author)")
                        .font(fontManager.captionFont)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                if showFullContent {
                    Text("Added \(formatDate(quote.dateAdded))")
                        .font(fontManager.captionFont)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
            
            // Tags/Categories
            HStack {
                ForEach(quote.categories.prefix(2), id: \.self) { category in
                    CategoryChip(categoryName: category, viewModel: viewModel)
                }
                
                ForEach(quote.tags.prefix(showFullContent ? 3 : 1), id: \.self) { tag in
                    TagChip(tag: tag)
                }
                
                Spacer()
                
                if !showFullContent {
                    Button(action: {
                        viewModel.toggleFavorite(quote)
                        // Update local state
                        if let updatedQuote = viewModel.quotes.first(where: { $0.id == quote.id }) {
                            quote = updatedQuote
                        }
                    }) {
                        Image(systemName: quote.isFavorite ? "star.fill" : "star")
                            .foregroundColor(quote.isFavorite ? .yellow : .gray)
                    }
                    
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct CategoryChip: View {
    let categoryName: String
    let viewModel: QuoteViewModel
    
    var category: Category? {
        viewModel.categories.first { $0.name == categoryName }
    }
    
    var body: some View {
        Text(categoryName)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(category?.color ?? .blue)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
}

struct TagChip: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.purple.opacity(0.2))
            .foregroundColor(.purple)
            .cornerRadius(12)
    }
}

struct QuoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuoteViewModel()
        let sampleQuote = Quote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt",
            categories: ["Dreams"],
            tags: ["Dreams", "Future"],
            isFavorite: true
        )
        
        return Group {
            QuoteCardView(quote: sampleQuote, viewModel: viewModel, onTap: {})
                .previewLayout(.sizeThatFits)
                .padding()
            
            QuoteCardView(quote: sampleQuote, viewModel: viewModel, showFullContent: true, onTap: {})
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
