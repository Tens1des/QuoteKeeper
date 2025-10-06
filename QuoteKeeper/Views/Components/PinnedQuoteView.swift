import SwiftUI

struct PinnedQuoteView: View {
    let quote: Quote
    let viewModel: QuoteViewModel
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with PINNED and bookmark
            HStack {
                Text("PINNED")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            
            // Quote text
            Text("\"\(quote.text)\"")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            // Author
            Text("- \(quote.author)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            // Tags
            HStack(spacing: 8) {
                ForEach(quote.categories.prefix(2), id: \.self) { category in
                    Text(category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
                
                ForEach(quote.tags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.8), // Dark purple
                    Color(red: 0.6, green: 0.3, blue: 0.9)  // Lighter purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: Color.purple.opacity(0.3), radius: 15, x: 0, y: 8)
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
