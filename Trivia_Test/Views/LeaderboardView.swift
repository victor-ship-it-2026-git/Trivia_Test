import SwiftUI

struct LeaderboardView: View {
    let goHome: () -> Void
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    @State private var selectedFilter: LeaderboardFilter = .all
    @State private var filteredLeaderboard: [LeaderboardEntry] = []
    @State private var showFilterMenu = false
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
                                LeaderboardRow(entry: entry, rank: index + 1)
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
            applyFilter()
        }
        .onChange(of: firebaseManager.leaderboard) { oldValue, newValue in
            applyFilter()
        }
        .onChange(of: selectedFilter) { oldValue, newValue in
            withAnimation {
                applyFilter()
            }
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
