import SwiftUI

struct LeaderboardView: View {
    let goHome: () -> Void
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    @State private var selectedFilter: LeaderboardFilter = .all
    @State private var filteredLeaderboard: [LeaderboardEntry] = []
    @State private var showFilterMenu = false
    @State private var isGeneratingShare = false
    @State private var selectedEntryForShare: LeaderboardEntry?
    @Environment(\.colorScheme) var colorScheme
    
    enum LeaderboardFilter: String, CaseIterable {
        case all = "All"
        case rookie = "Rookie"
        case amateur = "Amateur"
        case pro = "Pro"
        case master = "Master"
        case legend = "Legend"
        case genius = "Genius"
        
        var icon: String {
            switch self {
            case .all: return "chart.bar.fill"
            case .rookie: return "🌱"
            case .amateur: return "📚"
            case .pro: return "⚡️"
            case .master: return "👑"
            case .legend: return "🔥"
            case .genius: return "🧠"
            }
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ?
                    [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                    [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: goHome) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Filter Button
                    Button(action: {
                        showFilterMenu = true
                    }) {
                        HStack(spacing: 6) {
                            if selectedFilter == .all {
                                Image(systemName: selectedFilter.icon)
                            } else {
                                Text(selectedFilter.icon)
                            }
                            Text(selectedFilter.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                        )
                    }
                }
                .padding()
                
                // Title
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.system(size: 50))
                    
                    Text("Global Leaderboard")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.dynamicText)
                    
                    Text("\(filteredLeaderboard.count) players")
                        .font(.subheadline)
                        .foregroundColor(.dynamicSecondaryText)
                }
                
                // Loading Indicator
                if firebaseManager.isLoading && filteredLeaderboard.isEmpty {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                    Text("Loading leaderboard...")
                        .font(.subheadline)
                        .foregroundColor(.dynamicSecondaryText)
                        .padding(.top)
                    Spacer()
                } else if filteredLeaderboard.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "trophy.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.dynamicSecondaryText)
                        Text("No scores yet!")
                            .font(.title2)
                            .foregroundColor(.dynamicSecondaryText)
                        Text("Play a game to get on the leaderboard")
                            .font(.subheadline)
                            .foregroundColor(.dynamicSecondaryText.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(filteredLeaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRowWithShare(
                                    entry: entry,
                                    rank: index + 1,
                                    onShare: {
                                        shareLeaderboardEntry(entry: entry, rank: index + 1)
                                    }
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding()
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Leaderboard")
              AnalyticsManager.shared.logLeaderboardViewed(filter: selectedFilter.rawValue)
              
        
            applyFilter()
        }
        .onChange(of: firebaseManager.leaderboard) { oldValue, newValue in
            applyFilter()
        }
        .onChange(of: selectedFilter) { oldValue, newValue in
            withAnimation {
                applyFilter()
            }
            AnalyticsManager.shared.logLeaderboardViewed(filter: newValue.rawValue)

        }
        .sheet(isPresented: $showFilterMenu) {
            FilterMenuView(selectedFilter: $selectedFilter)
        }
        .alert("Error", isPresented: .constant(firebaseManager.errorMessage != nil)) {
            Button("OK") {
                firebaseManager.errorMessage = nil
            }
        } message: {
            if let error = firebaseManager.errorMessage {
                Text(error)
            }
        }
    }
    
    private func applyFilter() {
        switch selectedFilter {
        case .all:
            filteredLeaderboard = firebaseManager.leaderboard
        case .rookie:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Rookie" }
        case .amateur:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Amateur" }
        case .pro:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Pro" }
        case .master:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Master" }
        case .legend:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Legend" }
        case .genius:
            filteredLeaderboard = firebaseManager.leaderboard.filter { $0.difficulty == "Genius" }
        }
    }
    
    // MARK: - Share Leaderboard Entry
    
    func shareLeaderboardEntry(entry: LeaderboardEntry, rank: Int) {
        
        AnalyticsManager.shared.logShareInitiated(
               shareType: "leaderboard",
               category: QuizCategory(rawValue: entry.category),
               difficulty: Difficulty(rawValue: entry.difficulty),
               score: entry.score
           )
           AnalyticsManager.shared.logLeaderboardEntryShared(rank: rank)
        
        isGeneratingShare = true
        HapticManager.shared.success()
        
        
        
        // Generate share card
        let shareCard = LeaderboardShareCard(
            playerName: entry.playerName,
            rank: rank,
            score: entry.score,
            totalQuestions: entry.totalQuestions,
            category: entry.category,
            difficulty: entry.difficulty
        )
        
        // Generate image on main thread
        Task { @MainActor in
            if let image = ShareManager.shared.generateShareImage(from: AnyView(shareCard)) {
                AnalyticsManager.shared.logShareCompleted(shareType: "leaderboard")

                let shareText = ShareManager.shared.generateLeaderboardShareText(
                    playerName: entry.playerName,
                    rank: rank,
                    score: entry.score,
                    total: entry.totalQuestions
                )
                
                isGeneratingShare = false
                
                // Get root view controller
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else {
                    return
                }
                
                ShareManager.shared.shareToSocialMedia(
                    image: image,
                    text: shareText,
                    from: rootVC
                )
            } else {
                isGeneratingShare = false
            }
        }
    }
}

// MARK: - Leaderboard Row with Share Button
struct LeaderboardRowWithShare: View {
    let entry: LeaderboardEntry
    let rank: Int
    let onShare: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text(rankEmoji)
                .font(.title)
                .frame(width: 50)
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                HStack(spacing: 10) {
                    Text(entry.category)
                        .font(.caption)
                        .foregroundColor(.dynamicText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.2))
                        .cornerRadius(8)
                    
                    Text(entry.difficulty)
                        .font(.caption)
                        .foregroundColor(.dynamicText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(entry.difficulty).opacity(colorScheme == .dark ? 0.25 : 0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.percentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("\(entry.score)/\(entry.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
            }
            
            // Share Button
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                    )
            }
        }
        .padding()
        .background(Color.dynamicCardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2)
    }
    
    func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Rookie": return .green
        case "Amateur": return .cyan
        case "Pro": return .blue
        case "Master": return .purple
        case "Legend": return .orange
        case "Genius": return .red
        default: return .gray
        }
    }
}

// MARK: - Filter Menu View
struct FilterMenuView: View {
    @Binding var selectedFilter: LeaderboardView.LeaderboardFilter
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(LeaderboardView.LeaderboardFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedFilter = filter
                                dismiss()
                            }) {
                                HStack {
                                    if filter == .all {
                                        Image(systemName: filter.icon)
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                            .frame(width: 30)
                                    } else {
                                        Text(filter.icon)
                                            .font(.title3)
                                            .frame(width: 30)
                                    }
                                    
                                    Text(filter.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.dynamicText)
                                    
                                    Spacer()
                                    
                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedFilter == filter ?
                                            Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15) :
                                            Color.dynamicCardBackground)
                                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Filter by Difficulty")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}
