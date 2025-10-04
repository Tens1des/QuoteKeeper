import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @State private var showingAllAchievements = false
    
    // Computed properties to break up complex expressions
    private var categoriesWithQuotes: [Category] {
        viewModel.categories.filter { category in
            viewModel.quotesByCategory(category.name).count > 0
        }
    }
    
    private var hasNoCategoryData: Bool {
        viewModel.categories.allSatisfy { category in
            viewModel.quotesByCategory(category.name).count == 0
        }
    }
    
    private var unlockedAchievements: [Achievement] {
        viewModel.achievements.filter { $0.isUnlocked }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    statsCardsView
                    achievementsSectionView
                    categoryDistributionView
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        HStack {
            Text("Statistics")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                // Action for archive or history
            }) {
                Image(systemName: "archivebox")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    private var statsCardsView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Total Quotes",
                value: "\(viewModel.totalQuotesCount)",
                icon: "doc.text.fill",
                color: .blue
            )
            
            StatCard(
                title: "Favorites",
                value: "\(viewModel.favoritesCount)",
                icon: "star.fill",
                color: .yellow
            )
            
            StatCard(
                title: "Categories",
                value: "\(viewModel.categoriesCount)",
                icon: "folder.fill",
                color: .blue
            )
            
            StatCard(
                title: "This Month",
                value: "\(viewModel.thisMonthQuotesCount)",
                icon: "calendar",
                color: .green
            )
        }
        .padding(.horizontal)
    }
    
    private var achievementsSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(unlockedAchievements.count) / \(viewModel.achievements.count)")
                    .font(.headline)
                    .foregroundColor(.purple)
            }
            .padding(.horizontal)
            
            achievementsListView
        }
    }
    
    private var achievementsListView: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.achievements.prefix(showingAllAchievements ? viewModel.achievements.count : 3)) { achievement in
                AchievementCard(achievement: achievement)
            }
            
            if unlockedAchievements.isEmpty {
                emptyAchievementsView
            }
            
            if !showingAllAchievements && viewModel.achievements.count > 3 {
                viewAllAchievementsButton
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyAchievementsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "trophy")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No achievements yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start adding quotes to unlock achievements")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var viewAllAchievementsButton: some View {
        Button(action: {
            showingAllAchievements = true
        }) {
            HStack {
                Text("View All Achievements")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.purple)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var categoryDistributionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Distribution")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            categoryList
            
            if hasNoCategoryData {
                emptyCategoryDataView
            }
        }
    }
    
    private var categoryList: some View {
        VStack(spacing: 12) {
            ForEach(categoriesWithQuotes.sorted(by: { 
                viewModel.quotesByCategory($0.name).count > viewModel.quotesByCategory($1.name).count 
            }).prefix(5)) { category in
                CategoryDistributionRow(category: category, viewModel: viewModel)
            }
        }
        .padding(.horizontal)
    }
    
    private var emptyCategoryDataView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 30))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No category data yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add quotes to see category distribution")
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(Circle())
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    private var iconColor: Color {
        achievement.isUnlocked ? Color.orange : Color.gray
    }
    
    private var backgroundOpacity: Double {
        achievement.isUnlocked ? 0.1 : 0.0
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: achievement.iconName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if achievement.isUnlocked {
                    Text("Unlocked: \(formatDate(achievement.dateUnlocked ?? Date()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    // Progress
                    HStack {
                        Text("Progress: \(achievement.progress)/\(achievement.goal)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "lock")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(achievement.isUnlocked ? Color.orange.opacity(backgroundOpacity) : Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct CategoryDistributionRow: View {
    let category: Category
    let viewModel: QuoteViewModel
    
    private var quoteCount: Int {
        viewModel.quotesByCategory(category.name).count
    }
    
    private var percentage: Double {
        guard viewModel.totalQuotesCount > 0 else { return 0 }
        return Double(quoteCount) / Double(viewModel.totalQuotesCount) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(category.color)
                    .frame(width: 30)
                
                Text(category.name)
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(quoteCount)")
                    .font(.headline)
                    .foregroundColor(category.color)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(category.color)
                        .frame(width: max(0, min(CGFloat(percentage) / 100 * geometry.size.width, geometry.size.width)), height: 8)
                        .cornerRadius(4)
                        .animation(.easeInOut(duration: 0.3), value: percentage)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(8)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView(viewModel: QuoteViewModel())
    }
}
