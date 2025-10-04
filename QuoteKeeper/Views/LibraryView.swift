import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var selectedCategory: String?
    @State private var showingAddQuote = false
    @State private var showingQuoteDetail: Quote?
    @State private var showingRandomQuote = false
    @State private var showingSearchView = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Pinned quote if available
                        if let pinnedQuote = viewModel.pinnedQuote {
                            PinnedQuoteView(quote: pinnedQuote, viewModel: viewModel) {
                                showingQuoteDetail = pinnedQuote
                            }
                            .padding(.horizontal)
                        }
                        
                        // Empty state if no quotes
                        if viewModel.quotes.isEmpty {
                            VStack(spacing: 20) {
                                Spacer()
                                
                                Image(systemName: "quote.bubble")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Your collection is empty".localized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Add your first quote to get started".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Button(action: {
                                    showingAddQuote = true
                                }) {
                                    Text("Add Your First Quote".localized)
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        } else {
                            // Category filters
                            FilterChipsView(
                                selectedCategory: $selectedCategory,
                                categories: viewModel.categories
                            )
                            .padding(.vertical, 8)
                            
                            // Stats row
                            StatsRowView(
                                totalQuotes: viewModel.totalQuotesCount,
                                favorites: viewModel.favoritesCount,
                                categories: viewModel.categoriesCount
                            ) {
                                // Navigate to stats view
                            }
                            .padding(.horizontal)
                            
                            // Quotes list
                            LazyVStack(spacing: 16) {
                                ForEach(filteredQuotes) { quote in
                                    QuoteCardView(quote: quote, viewModel: viewModel) {
                                        showingQuoteDetail = quote
                                    }
                                    .padding(.horizontal)
                                    .contextMenu {
                                        Button {
                                            viewModel.toggleFavorite(quote)
                                        } label: {
                                            Label(
                                                quote.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                                systemImage: quote.isFavorite ? "star.slash" : "star"
                                            )
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
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            viewModel.toggleFavorite(quote)
                                        } label: {
                                            Label("Favorite", systemImage: "star")
                                        }
                                        .tint(.yellow)
                                    }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.deleteQuote(quote)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .id(localizationManager.currentLanguage)
                }
                
                // Add button
                Button(action: {
                    showingAddQuote = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.purple)
                        .clipShape(Circle())
                        .shadow(color: Color.purple.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("QuoteKeeper")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Search action
                        showingSearchView = true
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Profile action
                    }) {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddQuote) {
                AddEditQuoteView(viewModel: viewModel)
            }
            .sheet(item: $showingQuoteDetail) { quote in
                QuoteDetailView(quote: quote, viewModel: viewModel)
            }
            .sheet(isPresented: $showingRandomQuote) {
                RandomQuoteView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSearchView) {
                SearchView(viewModel: viewModel)
            }
        }
    }
    
    private var filteredQuotes: [Quote] {
        if let category = selectedCategory {
            return viewModel.quotesByCategory(category)
        } else {
            return viewModel.quotes
        }
    }
}

/*struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}*/
