import SwiftUI

struct AddEditQuoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    
    @State private var quoteText: String = ""
    @State private var author: String = ""
    @State private var selectedCategories: [String] = []
    @State private var tags: [String] = []
    @State private var tagInput: String = ""
    @State private var isFavorite: Bool = false
    @State private var showingCategoryPicker = false
    @State private var showingNewCategorySheet = false
    
    private let isEditing: Bool
    private let editingQuote: Quote?
    
    // For new quote
    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        self.isEditing = false
        self.editingQuote = nil
    }
    
    // For editing existing quote
    init(viewModel: QuoteViewModel, quote: Quote) {
        self.viewModel = viewModel
        self.isEditing = true
        self.editingQuote = quote
        
        // Initialize state properties with quote values
        _quoteText = State(initialValue: quote.text)
        _author = State(initialValue: quote.author)
        _selectedCategories = State(initialValue: quote.categories)
        _tags = State(initialValue: quote.tags)
        _isFavorite = State(initialValue: quote.isFavorite)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Quote Text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quote Text")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $quoteText)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        HStack {
                            Text("\(quoteText.count) / 1000")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Select text to apply formatting")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Formatting toolbar
                        HStack(spacing: 16) {
                            Button(action: { applyFormatting(.bold) }) {
                                Image(systemName: "bold")
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: { applyFormatting(.italic) }) {
                                Image(systemName: "italic")
                                    .foregroundColor(.primary)
                            }
                            
                            Button(action: { applyFormatting(.quote) }) {
                                Image(systemName: "quote.bubble")
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Author
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Author")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Author name (optional)", text: $author)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Category
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showingCategoryPicker = true
                        }) {
                            HStack {
                                if selectedCategories.isEmpty {
                                    Text("Select category...")
                                        .foregroundColor(.gray)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(selectedCategories, id: \.self) { category in
                                                CategoryChip(categoryName: category, viewModel: viewModel)
                                            }
                                        }
                                    }
                                }
                                
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Button(action: {
                            // Create new category action
                            showingNewCategorySheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Create new category")
                                    .foregroundColor(.purple)
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 4)
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Add tags...", text: $tagInput)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        // Tag chips
                        if !tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack {
                                            Text(tag)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.purple.opacity(0.2))
                                                .foregroundColor(.purple)
                                                .cornerRadius(12)
                                            
                                            Button(action: {
                                                removeTag(tag)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.purple)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        
                        // Tag suggestions
                        HStack {
                            Text("Suggestions:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ForEach(["inspiring", "wisdom", "growth"], id: \.self) { suggestion in
                                Button(action: {
                                    if !tags.contains(suggestion) {
                                        tags.append(suggestion)
                                    }
                                }) {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Options
                    VStack(alignment: .leading, spacing: 16) {
                        Toggle("Mark as favorite", isOn: $isFavorite)
                            .tint(.yellow)
                        
                        if isEditing {
                            Toggle("Pin to home screen", isOn: .constant(editingQuote?.isPinned ?? false))
                                .tint(.blue)
                                .disabled(true) // Can only pin from detail view
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Edit Quote" : "Add Quote")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveQuote()
                    }
                    .disabled(quoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.headline)
                    .foregroundColor(.purple)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(
                    categories: viewModel.categories,
                    selectedCategories: $selectedCategories
                )
            }
            .sheet(isPresented: $showingNewCategorySheet) {
                CategoryFormView(viewModel: viewModel, onSave: { category in
                    // Auto-select newly created category
                    if !selectedCategories.contains(category.name) {
                        selectedCategories.append(category.name)
                    }
                })
            }
        }
    }
    
    private func applyFormatting(_ format: TextFormat) {
        // This would normally apply formatting, but for this demo we'll just add symbols
        switch format {
        case .bold:
            quoteText += " **bold** "
        case .italic:
            quoteText += " *italic* "
        case .quote:
            quoteText += " \"quote\" "
        }
    }
    
    private func addTag() {
        let newTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newTag.isEmpty && !tags.contains(newTag) {
            tags.append(newTag)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveQuote() {
        if isEditing, let quote = editingQuote {
            // Update existing quote
            var updatedQuote = quote
            updatedQuote.text = quoteText
            updatedQuote.author = author
            updatedQuote.categories = selectedCategories
            updatedQuote.tags = tags
            updatedQuote.isFavorite = isFavorite
            
            viewModel.updateQuote(updatedQuote)
        } else {
            // Create new quote
            let newQuote = Quote(
                text: quoteText,
                author: author,
                categories: selectedCategories,
                tags: tags,
                isFavorite: isFavorite
            )
            
            viewModel.addQuote(newQuote)
        }
        
        dismiss()
    }
    
    enum TextFormat {
        case bold, italic, quote
    }
}

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategories: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        toggleCategory(category.name)
                    }) {
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundColor(category.color)
                            
                            Text(category.name)
                            
                            Spacer()
                            
                            if selectedCategories.contains(category.name) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
}

struct AddEditQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = QuoteViewModel()
        
        return Group {
            // Add new quote
            AddEditQuoteView(viewModel: viewModel)
                .previewDisplayName("Add Quote")
            
            // Edit existing quote
            if let sampleQuote = viewModel.quotes.first {
                AddEditQuoteView(viewModel: viewModel, quote: sampleQuote)
                    .previewDisplayName("Edit Quote")
            }
        }
    }
}
