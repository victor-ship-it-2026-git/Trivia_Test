import SwiftUI

struct LeaderboardView: View {
    let goHome: () -> Void
    @State private var leaderboard: [LeaderboardEntry] = []
    @Environment(\.colorScheme) var colorScheme
    
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
                HStack {
                    Button(action: goHome) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    
                    Button(action: {
                        LeaderboardManager.shared.clearLeaderboard()
                        leaderboard = []
                    }) {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                Text("🏆 Leaderboard")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.dynamicText)
                
                if leaderboard.isEmpty {
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
                            ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            leaderboard = LeaderboardManager.shared.getLeaderboard()
        }
    }
}
