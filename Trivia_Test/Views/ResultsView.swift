import SwiftUI

struct ResultsView: View {
    @ObservedObject var presenter: GamePresenter
    let playAgain: () -> Void
    let goHome: () -> Void
    let showLeaderboard: () -> Void
    @State private var showNameInput = false
    @State private var playerName = ""
    @State private var savedToLeaderboard = false
    @State private var showUnlockAnimation = false
    @State private var unlockedDifficulty: Difficulty?
    @StateObject private var unlockManager = DifficultyUnlockManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    var percentage: Int {
        guard presenter.totalQuestions > 0 else { return 0 }
        return (presenter.score * 100) / presenter.totalQuestions
    }
    
    var message: String {
        switch percentage {
        case 90...100: return "Outstanding! 🏆"
        case 70..<90: return "Great Job! 🎉"
        case 50..<70: return "Good Effort! 👍"
        default: return "Keep Practicing! 💪"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ?
                    [Color.blue.opacity(0.4), Color.purple.opacity(0.4)] :
                    [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text(message)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Text("\(presenter.score)/\(presenter.totalQuestions)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(percentage)% Correct")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text(presenter.selectedCategory.emoji)
                                .font(.title)
                            Text(presenter.selectedCategory.rawValue)
                                .font(.caption)
                        }
                        
                        VStack {
                            Text(presenter.selectedDifficulty.emoji)
                                .font(.title)
                            Text(presenter.selectedDifficulty.rawValue)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(40)
                .background(Color.white.opacity(colorScheme == .dark ? 0.15 : 0.2))
                .cornerRadius(20)
                
                // Unlock notification
                if let unlocked = unlockedDifficulty, showUnlockAnimation {
                    VStack(spacing: 10) {
                        Text("🎉 Level Unlocked!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                        
                        HStack(spacing: 8) {
                            Text(unlocked.emoji)
                                .font(.title)
                            Text(unlocked.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(unlocked.color.opacity(0.3))
                        )
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                if !savedToLeaderboard {
                    Button(action: { showNameInput = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Save to Leaderboard")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.yellow.opacity(0.8))
                        .cornerRadius(25)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: playAgain) {
                        Text("Play Again")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .blue)
                            .frame(width: 250, height: 60)
                            .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
                            .cornerRadius(30)
                    }
                    
                    Button(action: showLeaderboard) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Leaderboard")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(30)
                    }
                    
                    Button(action: goHome) {
                        Text("Home")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            checkAndUnlockNextDifficulty()
        }
        .sheet(isPresented: $showNameInput) {
            NameInputView(
                playerName: $playerName,
                onSave: {
                    saveToLeaderboard()
                    showNameInput = false
                    savedToLeaderboard = true
                }
            )
        }
    }
    
    func saveToLeaderboard() {
        let entry = LeaderboardEntry(
            id: UUID(),
            playerName: playerName.isEmpty ? "Anonymous" : playerName,
            score: presenter.score,
            totalQuestions: presenter.totalQuestions,
            category: presenter.selectedCategory.rawValue,
            difficulty: presenter.selectedDifficulty.rawValue,
            date: Date()
        )
        
        LeaderboardManager.shared.addEntry(entry)
    }
    
    func checkAndUnlockNextDifficulty() {
        // Unlock next difficulty if score is 70% or higher
        if percentage >= 70 {
            let difficulties = Difficulty.allCases
            guard let currentIndex = difficulties.firstIndex(of: presenter.selectedDifficulty),
                  currentIndex < difficulties.count - 1 else {
                return
            }
            
            let nextDifficulty = difficulties[currentIndex + 1]
            
            // Check if not already unlocked
            if !unlockManager.isDifficultyUnlocked(category: presenter.selectedCategory, difficulty: nextDifficulty) {
                unlockManager.unlockNextDifficulty(category: presenter.selectedCategory, completedDifficulty: presenter.selectedDifficulty)
                unlockedDifficulty = nextDifficulty
                
                // Show unlock animation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showUnlockAnimation = true
                    }
                }
            }
        }
    }
}
