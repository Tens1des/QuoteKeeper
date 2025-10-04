import SwiftUI

struct StatsRowView: View {
    let totalQuotes: Int
    let favorites: Int
    let categories: Int
    var onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            StatsRowStatItem(value: totalQuotes, label: "Total", icon: "doc.text.fill", color: .blue)
            Divider()
            StatsRowStatItem(value: favorites, label: "Favorites", icon: "star.fill", color: .yellow)
            Divider()
            StatsRowStatItem(value: categories, label: "Categories", icon: "folder.fill", color: .blue)
        }
        .frame(height: 60)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

struct StatsRowStatItem: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatsRowView_Previews: PreviewProvider {
    static var previews: some View {
        StatsRowView(totalQuotes: 127, favorites: 42, categories: 8, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
