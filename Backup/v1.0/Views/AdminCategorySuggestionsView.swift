
import SwiftUI

struct AdminCategorySuggestionsView: View {
    @StateObject private var suggestionManager = CategorySuggestionManager.shared
    @State private var suggestions: [CategorySuggestion] = []
    @State private var isLoading = true
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if suggestions.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.dynamicSecondaryText)
                        Text("No suggestions yet")
                            .font(.title2)
                            .foregroundColor(.dynamicSecondaryText)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(suggestions) { suggestion in
                                CategorySuggestionCard(suggestion: suggestion)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Category Suggestions")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Close") { dismiss() },
                trailing: Button(action: loadSuggestions) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                loadSuggestions()
            }
        }
    }
    
    private func loadSuggestions() {
        isLoading = true
        suggestionManager.getAllSuggestions { fetchedSuggestions in
            suggestions = fetchedSuggestions
            isLoading = false
        }
    }
}

struct CategorySuggestionCard: View {
    let suggestion: CategorySuggestion
    @Environment(\.colorScheme) var colorScheme
    
    var statusColor: Color {
        switch suggestion.status {
        case "pending": return .orange
        case "approved": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.categoryName)
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Text("Suggested by: \(suggestion.userName)")
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                }
                
                Spacer()
                
                Text(suggestion.status.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(statusColor))
            }
            
            Text(formatDate(suggestion.timestamp))
                .font(.caption2)
                .foregroundColor(.dynamicSecondaryText)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
