import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var showingEditProfile = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile header
                    VStack(spacing: 16) {
                        // Avatar
                        Image(systemName: viewModel.userProfile.avatarIconName)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.purple)
                            .clipShape(Circle())
                        
                        // Name and email
                        if viewModel.userProfile.name.isEmpty {
                            Text("Tap to set your name".localized)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        } else {
                            Text(viewModel.userProfile.name)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        
                        // Edit profile button
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Text("Edit Profile".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    // Account stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("ACCOUNT STATS".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            ProfileStatItem(value: viewModel.totalQuotesCount, label: "Quotes".localized)
                            
                            Divider()
                                .frame(height: 40)
                            
                            ProfileStatItem(value: viewModel.favoritesCount, label: "Favorites".localized)
                            
                            Divider()
                                .frame(height: 40)
                            
                            ProfileStatItem(value: viewModel.categoriesCount, label: "Categories".localized)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SETTINGS".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Language
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Language".localized)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            Text("Choose interface language".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Language buttons
                            HStack(spacing: 10) {
                                LanguageButton(
                                    title: "English",
                                    isSelected: localizationManager.currentLanguage == .english
                                ) {
                                    updateLanguage(.english)
                                }
                                
                                LanguageButton(
                                    title: "Русский",
                                    isSelected: localizationManager.currentLanguage == .russian
                                ) {
                                    updateLanguage(.russian)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Theme
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "moon")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                    .frame(width: 30, height: 30)
                                    .background(Color.purple.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Theme".localized)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            Text("Select app appearance".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Theme buttons
                            HStack(spacing: 10) {
                                ThemeButton(
                                    title: "Light".localized,
                                    isSelected: themeManager.currentTheme == .light
                                ) {
                                    updateTheme(.light)
                                }
                                
                                ThemeButton(
                                    title: "Dark".localized,
                                    isSelected: themeManager.currentTheme == .dark
                                ) {
                                    updateTheme(.dark)
                                }
                                
                                ThemeButton(
                                    title: "System".localized,
                                    isSelected: themeManager.currentTheme == .system
                                ) {
                                    updateTheme(.system)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Text size
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "textformat.size")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .frame(width: 30, height: 30)
                                    .background(Color.green.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Text Size".localized)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            
                            Text("Adjust quote text size".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Text size buttons
                            HStack(spacing: 10) {
                                TextSizeButton(
                                    title: "Small".localized,
                                    isSelected: fontManager.currentTextSize == .small
                                ) {
                                    updateTextSize(.small)
                                }
                                
                                TextSizeButton(
                                    title: "Standard".localized,
                                    isSelected: fontManager.currentTextSize == .standard
                                ) {
                                    updateTextSize(.standard)
                                }
                                
                                TextSizeButton(
                                    title: "Large".localized,
                                    isSelected: fontManager.currentTextSize == .large
                                ) {
                                    updateTextSize(.large)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Reset data button (for testing)
                        Button(action: {
                            viewModel.resetAllData()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                
                                Text("Reset All Data".localized)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
                .id(refreshID)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
        }
    }
    
    private func updateTheme(_ theme: UserProfile.Theme) {
        var updatedProfile = viewModel.userProfile
        updatedProfile.theme = theme
        viewModel.updateUserProfile(updatedProfile)
        themeManager.setTheme(theme)
    }
    
    
    private func updateLanguage(_ language: UserProfile.Language) {
        var updatedProfile = viewModel.userProfile
        updatedProfile.language = language
        viewModel.updateUserProfile(updatedProfile)
        
        // Update language immediately
        localizationManager.setLanguage(language)
        
        // Force UI refresh
        refreshID = UUID()
    }
    
    private func updateTextSize(_ textSize: UserProfile.TextSize) {
        var updatedProfile = viewModel.userProfile
        updatedProfile.textSize = textSize
        viewModel.updateUserProfile(updatedProfile)
        fontManager.setTextSize(textSize)
    }
    
    
}

struct ProfileStatItem: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(iconColor)
                    .frame(width: 30, height: 30)
                    .background(iconColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(value)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

struct ThemeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}


struct LanguageButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}

struct TextSizeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                action()
            }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.green : Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
        }
    }
}


struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuoteViewModel
    
    @State private var name: String
    @State private var avatarIconName: String
    
    private let availableAvatars = [
        "person.fill", "person.crop.circle.fill", "person.fill.viewfinder",
        "paintbrush.fill", "pencil.and.outline", "book.fill",
        "graduationcap.fill", "briefcase.fill", "heart.fill",
        "star.fill", "moon.stars.fill", "sun.max.fill"
    ]
    
    init(viewModel: QuoteViewModel) {
        self.viewModel = viewModel
        _name = State(initialValue: viewModel.userProfile.name)
        _avatarIconName = State(initialValue: viewModel.userProfile.avatarIconName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $name)
                }
                
                Section(header: Text("Avatar")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableAvatars, id: \.self) { icon in
                            Button(action: {
                                avatarIconName = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title)
                                    .foregroundColor(avatarIconName == icon ? .white : .purple)
                                    .frame(width: 50, height: 50)
                                    .background(avatarIconName == icon ? Color.purple : Color.clear)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.purple, lineWidth: avatarIconName == icon ? 0 : 2)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.headline)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = viewModel.userProfile
        updatedProfile.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedProfile.avatarIconName = avatarIconName
        
        viewModel.updateUserProfile(updatedProfile)
        dismiss()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: QuoteViewModel())
    }
}
