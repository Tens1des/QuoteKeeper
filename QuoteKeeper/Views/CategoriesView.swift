import SwiftUI

struct CategoriesView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var showingAddCategory = false
    @State private var showingEditCategory: Category?
    @State private var showingDeleteAlert = false
    @State private var categoryToDelete: Category?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Categories")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(viewModel.categories.count)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "square.grid.2x2")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Text("Organize your quotes by topics and themes")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple)
                    )
                    .padding(.horizontal)
                    
                    // Create new category button
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Create New Category")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // Categories grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.categories) { category in
                            CategoryCard(
                                category: category,
                                quoteCount: viewModel.quotesByCategory(category.name).count,
                                onEdit: {
                                    showingEditCategory = category
                                },
                                onDelete: {
                                    categoryToDelete = category
                                    showingDeleteAlert = true
                                }
                            )
                        }
                        
                        // Show message if no quotes in any category
                        if viewModel.quotes.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "folder")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("No quotes yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Add quotes to see them organized by categories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Categories")
            .sheet(isPresented: $showingAddCategory) {
                CategoryFormView(viewModel: viewModel)
            }
            .sheet(item: $showingEditCategory) { category in
                CategoryFormView(viewModel: viewModel, editingCategory: category)
            }
            .alert("Delete Category", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        viewModel.deleteCategory(category)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this category? Quotes will remain but the category will be removed from them.")
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let quoteCount: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and menu
            HStack {
                Image(systemName: category.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(category.color)
                    .clipShape(Circle())
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            
            // Category name
            Text(category.name)
                .font(.headline)
            
            // Quote count
            Text("\(quoteCount)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(category.color)
            
            Text("quotes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CategoryFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    var onSave: ((Category) -> Void)? = nil
    
    @State private var name: String = ""
    @State private var iconName: String = "book.fill"
    @State private var colorName: String = "blue"
    
    private let isEditing: Bool
    private let editingCategory: Category?
    
    // Available icons and colors for selection
    private let availableIcons = [
        "book.fill", "heart.fill", "star.fill", "lightbulb.fill", 
        "briefcase.fill", "moon.stars.fill", "face.smiling.fill", 
        "chart.line.uptrend.xyaxis", "quote.bubble.fill", "leaf.fill", 
        "music.note", "gamecontroller.fill", "globe", "flame.fill"
    ]
    
    private let availableColors = [
        "blue", "green", "purple", "pink", "orange", "red", "yellow"
    ]
    
    // For new category
    init(viewModel: QuoteViewModel, onSave: ((Category) -> Void)? = nil) {
        self.viewModel = viewModel
        self.isEditing = false
        self.editingCategory = nil
        self.onSave = onSave
    }
    
    // For editing existing category
    init(viewModel: QuoteViewModel, editingCategory: Category) {
        self.viewModel = viewModel
        self.isEditing = true
        self.editingCategory = editingCategory
        
        // Initialize state properties with category values
        _name = State(initialValue: editingCategory.name)
        _iconName = State(initialValue: editingCategory.iconName)
        _colorName = State(initialValue: editingCategory.colorName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category Details")) {
                    TextField("Category Name", text: $name)
                }
                
                Section(header: Text("Icon")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                iconName = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(iconName == icon ? .white : getColor(for: colorName))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        iconName == icon ? 
                                            getColor(for: colorName) : 
                                            Color(.systemBackground)
                                    )
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(getColor(for: colorName), lineWidth: iconName == icon ? 0 : 2)
                                    )
                            }
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: {
                                colorName = color
                            }) {
                                Circle()
                                    .fill(getColor(for: color))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .opacity(colorName == color ? 1 : 0)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                            }
                        }
                    }
                }
                
                Section(header: Text("Preview")) {
                    HStack {
                        Image(systemName: iconName)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(getColor(for: colorName))
                            .clipShape(Circle())
                        
                        Text(name.isEmpty ? "Category Name" : name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(isEditing ? "Edit Category" : "New Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.headline)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func getColor(for colorName: String) -> Color {
        switch colorName {
        case "blue":
            return .blue
        case "green":
            return .green
        case "purple":
            return .purple
        case "pink":
            return .pink
        case "orange":
            return .orange
        case "red":
            return .red
        case "yellow":
            return .yellow
        default:
            return .blue
        }
    }
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isEditing, let category = editingCategory {
            // Update existing category
            var updatedCategory = category
            updatedCategory.name = trimmedName
            updatedCategory.iconName = iconName
            updatedCategory.colorName = colorName
            
            viewModel.updateCategory(updatedCategory)
            onSave?(updatedCategory)
        } else {
            // Create new category
            let newCategory = Category(
                name: trimmedName,
                iconName: iconName,
                colorName: colorName
            )
            
            viewModel.addCategory(newCategory)
            onSave?(newCategory)
        }
        
        dismiss()
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(viewModel: QuoteViewModel())
    }
}
