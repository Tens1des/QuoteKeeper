import SwiftUI

struct QuoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    @State private var quote: Quote
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingSimilarQuotes = false
    
    init(quote: Quote, viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        _quote = State(initialValue: quote)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with back button
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
                    
                    // Favorite button in header
                    Button(action: {
                        toggleFavorite()
                    }) {
                        Image(systemName: quote.isFavorite ? "star.fill" : "star")
                            .foregroundColor(quote.isFavorite ? .yellow : .white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 8)
                    
                    // More options button
                    Menu {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple)
                
                // Quote content
                VStack(alignment: .leading, spacing: 20) {
                    // Quote marks and text
                    VStack(alignment: .leading, spacing: 16) {
                        // Favorite indicator
                        if quote.isFavorite {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Favorite")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text("Added \(formatDate(quote.dateAdded))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Text("Added \(formatDate(quote.dateAdded))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
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
                            .lineSpacing(6)
                            .padding(.horizontal, 8)
                        
                        // Author
                        if !quote.author.isEmpty {
                            Text(quote.author)
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        
                        // Categories and tags
                        VStack(alignment: .leading, spacing: 12) {
                            if !quote.categories.isEmpty {
                                HStack {
                                    ForEach(quote.categories, id: \.self) { category in
                                        CategoryChip(categoryName: category, viewModel: viewModel)
                                    }
                                }
                            }
                            
                            if !quote.tags.isEmpty {
                                HStack {
                                    ForEach(quote.tags, id: \.self) { tag in
                                        TagChip(tag: tag)
                                    }
                                }
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        // Primary actions
                        HStack(spacing: 16) {
                            ActionButton(
                                title: "Edit",
                                icon: "pencil",
                                color: .purple
                            ) {
                                showingEditSheet = true
                            }
                            
                            ActionButton(
                                title: "Share",
                                icon: "square.and.arrow.up",
                                color: .blue
                            ) {
                                // Share action
                            }
                        }
                        
                        // Secondary actions
                        HStack(spacing: 16) {
                            ActionButton(
                                title: "Pin",
                                icon: quote.isPinned ? "pin.fill" : "pin",
                                color: .blue
                            ) {
                                togglePin()
                            }
                            
                            ActionButton(
                                title: "Delete",
                                icon: "trash",
                                color: .red
                            ) {
                                showingDeleteAlert = true
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    // Similar quotes section
                    VStack(alignment: .leading, spacing: 12) {
                        Button(action: {
                            showingSimilarQuotes.toggle()
                        }) {
                            HStack {
                                Text("Similar Quotes (3)")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Image(systemName: showingSimilarQuotes ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if showingSimilarQuotes {
                            // This would normally show similar quotes based on categories or tags
                            // For demo, we'll just show a couple of sample quotes
                            ForEach(viewModel.quotes.filter { 
                                $0.id != quote.id && 
                                !Set($0.categories).isDisjoint(with: Set(quote.categories))
                            }.prefix(3)) { similarQuote in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(similarQuote.text)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    
                                    if !similarQuote.author.isEmpty {
                                        Text("— \(similarQuote.author)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Divider()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showingEditSheet) {
            AddEditQuoteView(viewModel: viewModel, quote: quote)
        }
        .alert("Delete Quote", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteQuote(quote)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this quote? This action cannot be undone.")
        }
    }
    
    private func toggleFavorite() {
        viewModel.toggleFavorite(quote)
        // Update local state
        if let updatedQuote = viewModel.quotes.first(where: { $0.id == quote.id }) {
            quote = updatedQuote
        }
    }
    
    private func togglePin() {
        viewModel.togglePin(quote)
        // Update local state
        if let updatedQuote = viewModel.quotes.first(where: { $0.id == quote.id }) {
            quote = updatedQuote
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct QuoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuoteViewModel()
        if let sampleQuote = viewModel.quotes.first {
            QuoteDetailView(quote: sampleQuote, viewModel: viewModel)
        }
    }
}
