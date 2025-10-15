import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var selectedFilter: String? = "All"
    @State private var showingQuoteDetail: Quote?
    @State private var searchText = ""
    @State private var showingSearchView = false
    @State private var showingSortOptions = false
    @State private var sortOption: SortOption = .dateAdded
    
    private var filterOptions: [String] {
        ["All".localized] + viewModel.categories.map { $0.name }
    }
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added"
        case author = "Author"
        case category = "Category"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Favorites".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        // Show search view
                        showingSearchView = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filterOptions, id: \.self) { filter in
                            FilterButton(
                                title: filter,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Count and sort
                HStack {
                    Text("Showing".localized + " \(filteredFavorites.count) " + "favorites".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingSortOptions = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.caption)
                            
                            Text("Sort".localized)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                if filteredFavorites.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.5))
                        
                        Text("No favorites yet".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Mark quotes as favorites to see them here".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            // Navigate to library
                        }) {
                            Text("Browse Library".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding()
                } else {
                    // Favorites list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredFavorites) { quote in
                                FavoriteQuoteCard(
                                    quote: quote,
                                    viewModel: viewModel,
                                    dateAdded: formatDate(quote.dateAdded)
                                ) {
                                    showingQuoteDetail = quote
                                }
                                .contextMenu {
                                    Button {
                                        viewModel.toggleFavorite(quote)
                                    } label: {
                                        Label("Remove from Favorites", systemImage: "star.slash")
                                    }
                                    
                                    Button {
                                        viewModel.togglePin(quote)
                                    } label: {
                                        Label(
                                            quote.isPinned ? "Unpin Quote" : "Pin Quote",
                                            systemImage: quote.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    
                                    Button(role: .destructive) {
                                        viewModel.deleteQuote(quote)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        viewModel.toggleFavorite(quote)
                                    } label: {
                                        Label("Remove", systemImage: "star.slash")
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $showingQuoteDetail) { quote in
                QuoteDetailView(quote: quote, viewModel: viewModel)
            }
            .sheet(isPresented: $showingSearchView) {
                SearchView(viewModel: viewModel)
            }
            .actionSheet(isPresented: $showingSortOptions) {
                ActionSheet(
                    title: Text("Sort by"),
                    buttons: [
                        .default(Text("Date Added")) { sortOption = .dateAdded },
                        .default(Text("Author")) { sortOption = .author },
                        .default(Text("Category")) { sortOption = .category },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private var filteredFavorites: [Quote] {
        var quotes = viewModel.favoriteQuotes
        
        // Apply category filter
        if let filter = selectedFilter, filter != "All" {
            quotes = quotes.filter { $0.categories.contains(filter) }
        }
        
        // Apply search filter if needed
        if !searchText.isEmpty {
            quotes = quotes.filter { 
                $0.text.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateAdded:
            return quotes.sorted(by: { $0.dateAdded > $1.dateAdded })
        case .author:
            return quotes.sorted(by: { $0.author < $1.author })
        case .category:
            return quotes.sorted(by: { 
                $0.categories.first ?? "" < $1.categories.first ?? ""
            })
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct FavoriteQuoteCard: View {
    let quote: Quote
    let viewModel: QuoteViewModel
    let dateAdded: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Favorite indicator and date
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Added \(dateAdded)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Menu {
                    Button {
                        viewModel.toggleFavorite(quote)
                    } label: {
                        Label("Remove from Favorites", systemImage: "star.slash")
                    }
                    
                    Button {
                        // Share action
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Quote text
            Text(quote.text)
                .font(.body)
                .lineLimit(3)
            
            // Author
            if !quote.author.isEmpty {
                Text("— \(quote.author)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Categories/tags
            HStack {
                ForEach(quote.categories.prefix(2), id: \.self) { category in
                    CategoryChip(categoryName: category, viewModel: viewModel)
                }
                
                ForEach(quote.tags.prefix(1), id: \.self) { tag in
                    TagChip(tag: tag)
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
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: QuoteViewModel())
    }
}
