import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var selectedTag: String?
    @State private var selectedAuthor: String?
    @State private var showingQuoteDetail: Quote?
    
    var body: some View {
        VStack(spacing: 0) {
            // Search header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                
                TextField("Search by quote, author, tags...", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            // Filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Category filter
                    FilterMenu(
                        title: selectedCategory ?? "Category",
                        icon: "folder.fill",
                        color: .blue,
                        isActive: selectedCategory != nil
                    ) {
                        Menu {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            
                            ForEach(viewModel.categories) { category in
                                Button(category.name) {
                                    selectedCategory = category.name
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory ?? "Category")
                                Image(systemName: "chevron.down")
                            }
                        }
                    }
                    
                    // Tag filter
                    FilterMenu(
                        title: selectedTag ?? "Tag",
                        icon: "tag.fill",
                        color: .purple,
                        isActive: selectedTag != nil
                    ) {
                        Menu {
                            Button("All Tags") {
                                selectedTag = nil
                            }
                            
                            let allTags = Array(Set(viewModel.quotes.flatMap { $0.tags })).sorted()
                            ForEach(allTags, id: \.self) { tag in
                                Button(tag) {
                                    selectedTag = tag
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedTag ?? "Tag")
                                Image(systemName: "chevron.down")
                            }
                        }
                    }
                    
                    // Author filter
                    FilterMenu(
                        title: selectedAuthor ?? "Author",
                        icon: "person.fill",
                        color: .green,
                        isActive: selectedAuthor != nil
                    ) {
                        Menu {
                            Button("All Authors") {
                                selectedAuthor = nil
                            }
                            
                            let allAuthors = Array(Set(viewModel.quotes.map { $0.author }))
                                .filter { !$0.isEmpty }
                                .sorted()
                            
                            ForEach(allAuthors, id: \.self) { author in
                                Button(author) {
                                    selectedAuthor = author
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedAuthor ?? "Author")
                                Image(systemName: "chevron.down")
                            }
                        }
                    }
                    
                    // Clear all filters
                    if selectedCategory != nil || selectedTag != nil || selectedAuthor != nil {
                        Button(action: {
                            selectedCategory = nil
                            selectedTag = nil
                            selectedAuthor = nil
                        }) {
                            Text("Clear all")
                                .font(.subheadline)
                                .foregroundColor(.purple)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            // Results
            if searchResults.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Spacer()
                    
                    if searchText.isEmpty && selectedCategory == nil && selectedTag == nil && selectedAuthor == nil {
                        // Initial state
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Search for quotes")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Enter text to search by quote content, author, or tags")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    } else {
                        // No results state
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No results found")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Try different search terms or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            searchText = ""
                            selectedCategory = nil
                            selectedTag = nil
                            selectedAuthor = nil
                        }) {
                            Text("Show all quotes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                // Search results
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Text("\(searchResults.count) results")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(searchResults) { quote in
                            SearchResultCard(
                                quote: quote,
                                viewModel: viewModel,
                                searchText: searchText
                            ) {
                                showingQuoteDetail = quote
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(item: $showingQuoteDetail) { quote in
            QuoteDetailView(quote: quote, viewModel: viewModel)
        }
    }
    
    private var searchResults: [Quote] {
        var results = viewModel.quotes
        
        // Apply text search
        if !searchText.isEmpty {
            results = results.filter {
                $0.text.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
        
        // Apply category filter
        if let category = selectedCategory {
            results = results.filter { $0.categories.contains(category) }
        }
        
        // Apply tag filter
        if let tag = selectedTag {
            results = results.filter { $0.tags.contains(tag) }
        }
        
        // Apply author filter
        if let author = selectedAuthor {
            results = results.filter { $0.author == author }
        }
        
        return results
    }
}

struct FilterMenu<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let isActive: Bool
    let content: () -> Content
    
    var body: some View {
        Menu {
            content()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isActive ? .white : color)
                
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(isActive ? .white : .gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? color : Color.gray.opacity(0.1))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct SearchResultCard: View {
    let quote: Quote
    let viewModel: QuoteViewModel
    let searchText: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quote text with highlighted search term
            if searchText.isEmpty {
                Text(quote.text)
                    .font(.body)
                    .lineLimit(3)
            } else {
                highlightedText(quote.text, searchText: searchText)
                    .font(.body)
                    .lineLimit(3)
            }
            
            // Author
            if !quote.author.isEmpty {
                if searchText.isEmpty || !quote.author.localizedCaseInsensitiveContains(searchText) {
                    Text("— \(quote.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    HStack {
                        Text("— ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        highlightedText(quote.author, searchText: searchText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Categories/tags
            HStack {
                ForEach(quote.categories.prefix(1), id: \.self) { category in
                    CategoryChip(categoryName: category, viewModel: viewModel)
                }
                
                ForEach(quote.tags.filter { 
                    searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText)
                }.prefix(2), id: \.self) { tag in
                    if searchText.isEmpty || !tag.localizedCaseInsensitiveContains(searchText) {
                        TagChip(tag: tag)
                    } else {
                        HStack(spacing: 0) {
                            highlightedText(tag, searchText: searchText)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.2))
                                .foregroundColor(.purple)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                if quote.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
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
    
    private func highlightedText(_ text: String, searchText: String) -> some View {
        if searchText.isEmpty {
            return Text(text)
        }
        
        let components = text.components(separatedBy: searchText)
        
        if components.count <= 1 {
            return Text(text)
        }
        
        var result = Text("")
        
        for (index, component) in components.enumerated() {
            result = result + Text(component)
            
            if index < components.count - 1 {
                result = result + Text(searchText)
                    .foregroundColor(.purple)
                    .fontWeight(.bold)
            }
        }
        
        return result
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(viewModel: QuoteViewModel())
    }
}
