import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var showingRandomQuote = false
    @StateObject private var viewModel = QuoteViewModel()
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @State private var refreshID = UUID()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                LibraryView(viewModel: viewModel)
                    .tag(0)
                
                // Favorites view
                FavoritesView(viewModel: viewModel)
                    .tag(1)
                
                // Placeholder for Random tab
                Color.clear
                    .tag(2)
                
                // Stats view
                StatsView(viewModel: viewModel)
                    .tag(3)
                
                // Profile view
                ProfileView(viewModel: viewModel)
                    .tag(4)
            }
            
            // Custom tab bar
            HStack(spacing: 0) {
                ForEach(0..<5) { index in
                    Spacer()
                    
                    Button(action: {
                        if index == 2 {
                            // Show random quote
                            showingRandomQuote = true
                        } else {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: getIconName(for: index))
                                .font(.system(size: index == 2 ? 24 : 20))
                                .foregroundColor(getIconColor(for: index))
                            
                            if index != 2 {
                                Text(getTabName(for: index))
                                    .font(.caption2)
                                    .foregroundColor(selectedTab == index ? .purple : .gray)
                            }
                        }
                        .frame(width: index == 2 ? 60 : 60, height: index == 2 ? 60 : 44)
                        .background(index == 2 ? Color.purple : Color.clear)
                        .cornerRadius(index == 2 ? 30 : 0)
                        .offset(y: index == 2 ? -20 : 0)
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 70)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
            .id(localizationManager.currentLanguage)
        }
        .sheet(isPresented: $showingRandomQuote) {
            RandomQuoteView(viewModel: viewModel)
        }
    }
    
    private func getIconName(for index: Int) -> String {
        switch index {
        case 0:
            return "house"
        case 1:
            return "star"
        case 2:
            return "bolt.fill"
        case 3:
            return "chart.bar"
        case 4:
            return "person"
        default:
            return ""
        }
    }
    
    private func getTabName(for index: Int) -> String {
        switch index {
        case 0:
            return "Library".localized
        case 1:
            return "Favorites".localized
        case 2:
            return "Random".localized
        case 3:
            return "Stats".localized
        case 4:
            return "Profile".localized
        default:
            return ""
        }
    }
    
    private func getIconColor(for index: Int) -> Color {
        if index == 2 {
            return .white
        } else {
            return selectedTab == index ? .purple : .gray
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarView()
    }
}
