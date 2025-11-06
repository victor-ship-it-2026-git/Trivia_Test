import SwiftUI

struct LeaderboardView: View {
    let goHome: () -> Void
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    @State private var selectedFilter: LeaderboardFilter = .all
    @State private var filteredLeaderboard: [LeaderboardEntry] = []
    @State private var showFilterMenu = false
    @State private var isGeneratingShare = false
    @State private var selectedEntryForShare: LeaderboardEntry?
    @State private var currentUserName: String = ""
    @State private var isNavigating = false
    @State private var appearAnimation = false
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
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        guard !isNavigating else { return }
                        handleHomeNavigation()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isNavigating)
                    
                    Spacer()
                    
                    // Filter Button
                    Button(action: {
                        HapticManager.shared.selection()
                        showFilterMenu = true
                    }) {
                        HStack(spacing: 8) {
                            Text(selectedFilter.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(Color.purple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(22)
                    }
                    .disabled(isNavigating)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .opacity(appearAnimation && !isNavigating ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appearAnimation)
                .animation(.easeOut(duration: 0.2), value: isNavigating)
                
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 16)
                .opacity(appearAnimation ? 1 : 0)
                .scaleEffect(appearAnimation ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)
                
                // Title
                Text("Global Leaderboard")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .padding(.bottom, 20)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
                
                // Loading Indicator
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
                    .opacity(appearAnimation ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appearAnimation)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(Array(filteredLeaderboard.enumerated()), id: \.element.id) { index, entry in
                                makeLeaderboardRow(entry: entry, rank: index + 1)
                                    .opacity(appearAnimation ? 1 : 0)
                                    .offset(y: appearAnimation ? 0 : 30)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.05), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .disabled(isNavigating)
                }
            }
            
            // Fade overlay during navigation
            if isNavigating {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Leaderboard")
            AnalyticsManager.shared.logLeaderboardViewed(filter: selectedFilter.rawValue)
            
            // Get current user name from UserDefaults
            currentUserName = UserDefaults.standard.string(forKey: "LastSavedPlayerName") ?? ""
            print("🔍 Current user name from UserDefaults: '\(currentUserName)'")
            
            isNavigating = false
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            
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
    
    private func handleHomeNavigation() {
        HapticManager.shared.selection()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isNavigating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            goHome()
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
    
    // Share Leaderboard Entry
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

// Modern Leaderboard Row
struct LeaderboardRowModern: View {
    let entry: LeaderboardEntry
    let rank: Int
    let isCurrentUser: Bool
    let onShare: () -> Void
    
    var rankBadgeColor: Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray.opacity(0.7)
        case 3: return Color.orange.opacity(0.7)
        default: return Color.white
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankBadgeColor)
                    .frame(width: 44, height: 44)
                
                Text("\(rank)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(rank <= 3 ? .white : Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Text("\(entry.difficulty) of \(entry.category)")
                    .font(.system(size: 13))
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.score)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Text("pts")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            
            // Share Button (only for current user)
            if isCurrentUser {
                Button(action: {
                    HapticManager.shared.selection()
                    onShare()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.purple)
                        .frame(width: 36, height: 36)
                        .background(Color.purple.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(
            rank <= 3 ? Color.purple.opacity(0.1) : Color.white
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// Filter Menu View
struct FilterMenuView: View {
    @Binding var selectedFilter: LeaderboardView.LeaderboardFilter
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(LeaderboardView.LeaderboardFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                HapticManager.shared.selection()
                                selectedFilter = filter
                                dismiss()
                            }) {
                                HStack {
                                    if filter == .all {
                                        Image(systemName: filter.icon)
                                            .font(.title3)
                                            .foregroundColor(Color.purple)
                                            .frame(width: 30)
                                    } else {
                                        Text(filter.icon)
                                            .font(.title3)
                                            .frame(width: 30)
                                    }
                                    
                                    Text(filter.rawValue)
                                        .font(.headline)
                                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    
                                    Spacer()
                                    
                                    if selectedFilter == filter {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.purple)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedFilter == filter ? Color.purple.opacity(0.15) : Color.white)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
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
