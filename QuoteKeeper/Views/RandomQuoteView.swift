import SwiftUI

struct RandomQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    @State private var currentQuote: Quote?
    @State private var showingDetail = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.white)
                                Text("Daily Inspiration".localized)
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
                            Text("Random Quote".localized)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Discover wisdom from your collection".localized)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal)
                        
                        if let quote = currentQuote {
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
                                
                                // Categories and tags
                                VStack(alignment: .leading, spacing: 12) {
                                    if !quote.categories.isEmpty {
                                        HStack {
                                            ForEach(quote.categories.prefix(2), id: \.self) { category in
                                                CategoryChip(categoryName: category, viewModel: viewModel)
                                            }
                                        }
                                    }
                                    
                                    if !quote.tags.isEmpty {
                                        HStack {
                                            ForEach(quote.tags.prefix(2), id: \.self) { tag in
                                                TagChip(tag: tag)
                                            }
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Actions
                                HStack {
                                    Button(action: {
                                        if let quote = currentQuote {
                                            viewModel.toggleFavorite(quote)
                                            // Update current quote state
                                            if let updatedQuote = viewModel.quotes.first(where: { $0.id == quote.id }) {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    currentQuote = updatedQuote
                                                }
                                            }
                                        }
                                    }) {
                                        Label("Favorite".localized, systemImage: currentQuote?.isFavorite ?? false ? "star.fill" : "star")
                                            .font(.subheadline)
                                            .foregroundColor(currentQuote?.isFavorite ?? false ? .yellow : .gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        loadRandomQuote()
                                    }) {
                                        Label("Another".localized, systemImage: "arrow.clockwise")
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
                            .padding(.horizontal)
                            .onTapGesture {
                                showingDetail = true
                            }
                        } else {
                            // Empty state
                            VStack(spacing: 20) {
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Text("No quotes available".localized)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                Text("Add some quotes to your collection first".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("Add Your First Quote".localized)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.purple)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }
                                .padding(.top)
                            }
                            .padding()
                        }
                        
                        // Bottom buttons
                        if currentQuote != nil {
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    loadRandomQuote()
                                }) {
                                    HStack {
                                        Image(systemName: "shuffle")
                                        Text("Another One".localized)
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
                                    dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                            
                            // Counter
                            if let quote = currentQuote {
                                Text("Quote \(viewModel.quotes.firstIndex(where: { $0.id == quote.id })?.advanced(by: 1) ?? 0) of \(viewModel.quotes.count) in your collection")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadRandomQuote()
        }
        .sheet(isPresented: $showingDetail) {
            if let quote = currentQuote {
                QuoteDetailView(quote: quote, viewModel: viewModel)
            }
        }
    }
    
    private func loadRandomQuote() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentQuote = viewModel.randomQuote()
        }
    }
}

struct RandomQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        RandomQuoteView(viewModel: QuoteViewModel())
    }
}
