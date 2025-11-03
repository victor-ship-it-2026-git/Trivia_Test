import SwiftUI

struct SettingsMenuView: View {
    let showShop: () -> Void
    let showLeaderboard: () -> Void
    @Binding var showDailyChallengeDetail: Bool
    @Binding var showSuggestCategory: Bool
    @State private var showAdminReports = false
    @State private var showNotificationSettings = false
    @State private var showPrivacyPolicy = false
    @State private var showDeleteDataConfirmation = false
    @State private var isDeletingData = false
    @State private var deleteSuccess = false
    @State private var deleteError: String?
    @State private var showQuestionsDiagnostic = false
    @State private var showLeaderboardSheet = false  // NEW: State for leaderboard sheet
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Coins Display
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(coinsManager.coins) Coins")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Menu Options
                    VStack(spacing: 15) {
                        SettingsMenuItem(icon: "cart.fill", title: "Shop", color: .orange) {
                            dismiss()
                            showShop()
                        }
                        
                        // UPDATED: Show leaderboard sheet instead of dismissing and navigating
                        SettingsMenuItem(icon: "trophy.fill", title: "Leaderboard", color: .blue) {
                            showLeaderboardSheet = true
                        }
                        
                        SettingsMenuItem(icon: "bell.badge.fill", title: "Notifications", color: .red) {
                            showNotificationSettings = true
                        }
                        
                        SettingsMenuItem(icon: "lightbulb.fill", title: "Suggest a Category", color: .yellow) {
                            showSuggestCategory = true
                        }
                        
                        // Divider between game features and data/legal items
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Delete Personal Data
                        SettingsMenuItem(icon: "trash.fill", title: "Delete Personal Data", color: .red) {
                            showDeleteDataConfirmation = true
                        }
                        
                        SettingsMenuItem(icon: "hand.raised.fill", title: "Privacy Policy", color: .green) {
                            showPrivacyPolicy = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .sheet(isPresented: $showAdminReports) {
            AdminReportsView()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showSuggestCategory) {
            SuggestCategoryView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        // NEW: Present leaderboard as a sheet
        .sheet(isPresented: $showLeaderboardSheet) {
            LeaderboardSheetView()
        }
        .confirmationDialog("Delete Personal Data", isPresented: $showDeleteDataConfirmation, titleVisibility: .visible) {
            Button("Delete My Data", role: .destructive) {
                deletePersonalData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your name from the global leaderboard. This action cannot be undone.")
        }
        .alert("Data Deleted", isPresented: $deleteSuccess) {
            Button("OK") {
                deleteSuccess = false
            }
        } message: {
            Text("Your personal data has been successfully deleted from the leaderboard.")
        }
        .alert("Error", isPresented: .constant(deleteError != nil)) {
            Button("OK") {
                deleteError = nil
            }
        } message: {
            if let error = deleteError {
                Text(error)
            }
        }
        .overlay {
            if isDeletingData {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Deleting data...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    )
                }
            }
        }
    }
    
    private func deletePersonalData() {
        guard let playerName = UserDefaults.standard.string(forKey: "LastSavedPlayerName"),
              !playerName.isEmpty else {
            deleteError = "No personal data found to delete."
            return
        }
        
        isDeletingData = true
        
        firebaseManager.deleteUserEntries(playerName: playerName) { result in
            DispatchQueue.main.async {
                isDeletingData = false
                
                switch result {
                case .success(let count):
                    if count > 0 {
                        UserDefaults.standard.removeObject(forKey: "LastSavedPlayerName")
                        deleteSuccess = true
                        print("✅ Successfully deleted \(count) entries for \(playerName)")
                    } else {
                        deleteError = "No leaderboard entries found for your name."
                    }
                    
                case .failure(let error):
                    deleteError = "Failed to delete data: \(error.localizedDescription)"
                    print("❌ Error deleting entries: \(error.localizedDescription)")
                }
            }
        }
    }
}

// NEW: Leaderboard Sheet View (wrapper without navigation changes)
struct LeaderboardSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            LeaderboardContentView()
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Done") {
                    dismiss()
                })
        }
    }
}

// NEW: Extracted Leaderboard Content (reusable)
struct LeaderboardContentView: View {
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    @State private var selectedFilter: LeaderboardFilter = .all
    @State private var filteredLeaderboard: [LeaderboardEntry] = []
    @State private var showFilterMenu = false
    @State private var isGeneratingShare = false
    @State private var selectedEntryForShare: LeaderboardEntry?
    @State private var currentUserName: String = ""
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
            Color(red: 0.97, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Filter Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(LeaderboardFilter.allCases, id: \.self) { filter in
                            FilterTabCompact(
                                title: filter.rawValue,
                                count: getCount(for: filter),
                                isSelected: selectedFilter == filter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Title
                Text("Global Leaderboard")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .padding(.bottom, 16)
                
                // Loading/Content
                if firebaseManager.isLoading && filteredLeaderboard.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.purple)
                        Text("Loading leaderboard...")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                } else if filteredLeaderboard.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "trophy.slash")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray)
                        Text("No scores yet!")
                            .font(.title2)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        Text("Play a game to get on the leaderboard")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(Array(filteredLeaderboard.enumerated()), id: \.element.id) { index, entry in
                                makeLeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Leaderboard")
            AnalyticsManager.shared.logLeaderboardViewed(filter: selectedFilter.rawValue)
            
            currentUserName = UserDefaults.standard.string(forKey: "LastSavedPlayerName") ?? ""
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
    }
    
    @ViewBuilder
    private func makeLeaderboardRow(entry: LeaderboardEntry, rank: Int) -> some View {
        let isUserEntry = !currentUserName.isEmpty && entry.playerName == currentUserName
        
        LeaderboardRowModern(
            entry: entry,
            rank: rank,
            isCurrentUser: isUserEntry,
            onShare: {
                shareLeaderboardEntry(entry: entry, rank: rank)
            }
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
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
    
    private func getCount(for filter: LeaderboardFilter) -> Int {
        if filter == .all {
            return firebaseManager.leaderboard.count
        }
        return firebaseManager.leaderboard.filter { $0.difficulty == filter.rawValue }.count
    }
    
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
        
        let shareCard = LeaderboardShareCard(
            playerName: entry.playerName,
            rank: rank,
            score: entry.score,
            totalQuestions: entry.totalQuestions,
            category: entry.category,
            difficulty: entry.difficulty
        )
        
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

// Compact Filter Tab for sheet view
struct FilterTabCompact: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Circle().fill(isSelected ? Color.white.opacity(0.3) : Color.gray))
                }
            }
            .foregroundColor(isSelected ? .white : Color(red: 0.1, green: 0.1, blue: 0.2))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
            )
        }
    }
}

// Settings Menu Item (unchanged)
struct SettingsMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
    }
}
