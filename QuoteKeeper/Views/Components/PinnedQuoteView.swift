import SwiftUI

struct PinnedQuoteView: View {
    let quote: Quote
    let viewModel: QuoteViewModel
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.white)
                Text("Daily Inspiration")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.2))
            .cornerRadius(20)
            
            // Title
            Text("Random Quote")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Discover wisdom from your collection")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // Quote card
            VStack(alignment: .leading, spacing: 16) {
                // Quote marks
                HStack {
                    Text("❝")
                        .font(.system(size: 40))
                        .foregroundColor(.pink.opacity(0.5))
                    Spacer()
                }
                
                // Quote text
                Text("\"\(quote.text)\"")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Author
                Text(quote.author)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Tags
                HStack {
                    ForEach(quote.categories.prefix(2), id: \.self) { category in
                        CategoryChip(categoryName: category, viewModel: viewModel)
                    }
                    
                    ForEach(quote.tags.prefix(2), id: \.self) { tag in
                        TagChip(tag: tag)
                    }
                }
                
                Divider()
                
                // Actions
                HStack {
                    Button(action: {
                        viewModel.toggleFavorite(quote)
                    }) {
                        Label("Favorite", systemImage: quote.isFavorite ? "star.fill" : "star")
                            .font(.subheadline)
                            .foregroundColor(quote.isFavorite ? .yellow : .gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Share action
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Show another random quote
                    }) {
                        Label("Another", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Bottom buttons
            HStack {
                Spacer()
                
                Button(action: {
                    // Show another random quote
                }) {
                    HStack {
                        Image(systemName: "shuffle")
                        Text("Another One")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(30)
                }
                
                Spacer()
                
                Button(action: {
                    // Close random quote view
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            // Counter
            Text("Quote \(viewModel.favoriteQuotes.firstIndex(where: { $0.id == quote.id })?.advanced(by: 1) ?? 0) of \(viewModel.favoriteQuotes.count) in your collection")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .onTapGesture {
            onTap()
        }
    }
}

struct PinnedQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuoteViewModel()
        let sampleQuote = Quote(
            text: "The future belongs to those who believe in the beauty of their dreams.",
            author: "Eleanor Roosevelt",
            categories: ["Dreams"],
            tags: ["Dreams", "Future"],
            isFavorite: true
        )
        
        return PinnedQuoteView(quote: sampleQuote, viewModel: viewModel, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
