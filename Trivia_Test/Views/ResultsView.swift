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
    @State private var isSavingToFirebase = false
    @State private var saveError: String?
    @State private var showSaveSuccess = false
    @State private var isGeneratingShare = false
    @StateObject private var unlockManager = DifficultyUnlockManager.shared
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
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
                
                // Save Success Message
                if showSaveSuccess {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                        Text("Saved to Global Leaderboard!")
                            .font(.headline)
                    }
                    .foregroundColor(.green)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.2))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Share Button - Prominent Position
                Button(action: shareAchievement) {
                    HStack(spacing: 10) {
                        if isGeneratingShare {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.title3)
                        }
                        Text(isGeneratingShare ? "Generating..." : "Share My Score")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 280, height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.teal]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 5)
                }
                .disabled(isGeneratingShare)
                
                // Save to Leaderboard Button
                if !savedToLeaderboard {
                    Button(action: { showNameInput = true }) {
                        HStack {
                            if isSavingToFirebase {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "star.fill")
                            }
                            Text(isSavingToFirebase ? "Saving..." : "Save to Global Leaderboard")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 50)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow.opacity(0.8), Color.orange.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.yellow.opacity(0.4), radius: 10)
                    }
                    .disabled(isSavingToFirebase)
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: playAgain) {
                        Text("Next Difficulty")
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
                            Text("View Global Leaderboard")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 280, height: 60)
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
            AnalyticsManager.shared.logScreenView(screenName: "Results")
                AnalyticsManager.shared.logResultsScreenViewed(
                    category: presenter.selectedCategory,
                    difficulty: presenter.selectedDifficulty,
                    score: presenter.score,
                    totalQuestions: presenter.totalQuestions,
                    percentage: percentage
                )
            checkAndUnlockNextDifficulty()
            
        }
        .sheet(isPresented: $showNameInput) {
            NameInputView(
                playerName: $playerName,
                onSave: {
                    saveToFirebaseLeaderboard()
                    showNameInput = false
                }
            )
        }
        .alert("Error Saving", isPresented: .constant(saveError != nil)) {
            Button("OK") {
                saveError = nil
            }
        } message: {
            if let error = saveError {
                Text(error)
            }
        }
    }
    
    // MARK: - Share Achievement
    
    func shareAchievement() {
        AnalyticsManager.shared.logShareInitiated(
                shareType: "results",
                category: presenter.selectedCategory,
                difficulty: presenter.selectedDifficulty,
                score: presenter.score
            )
            
            isGeneratingShare = true
            HapticManager.shared.success()
        
        // Use player name or default
        let name = playerName.isEmpty ? "Player" : playerName
        
        // Generate share card
        let shareCard = ResultsShareCard(
            score: presenter.score,
            totalQuestions: presenter.totalQuestions,
            category: presenter.selectedCategory.rawValue,
            difficulty: presenter.selectedDifficulty.rawValue,
            playerName: name
        )
        
        // Generate image on main thread
        Task { @MainActor in
            
            if let image = ShareManager.shared.generateShareImage(from: AnyView(shareCard)) {
                let shareText = ShareManager.shared.generateShareText(
                    score: presenter.score,
                    total: presenter.totalQuestions,
                    category: presenter.selectedCategory.rawValue,
                    difficulty: presenter.selectedDifficulty.rawValue
                    
                )
                
                isGeneratingShare = false
                
                // Get root view controller
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootVC = windowScene.windows.first?.rootViewController else {
                    return
                }
                AnalyticsManager.shared.logShareCompleted(shareType: "results")

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
    
    func saveToFirebaseLeaderboard() {
        isSavingToFirebase = true
        
        let entry = LeaderboardEntry(
            id: UUID(),
            playerName: playerName.isEmpty ? "Anonymous" : playerName,
            score: presenter.score,
            totalQuestions: presenter.totalQuestions,
            category: presenter.selectedCategory.rawValue,
            difficulty: presenter.selectedDifficulty.rawValue,
            date: Date()
        )
        
        // Save to Firebase
        firebaseManager.addEntry(entry) { result in
            DispatchQueue.main.async {
                isSavingToFirebase = false
                
                switch result {
                case .success:
                    AnalyticsManager.shared.logScoreSavedToLeaderboard(
                                    playerName: playerName,
                                    category: presenter.selectedCategory,
                                    difficulty: presenter.selectedDifficulty,
                                    score: presenter.score,
                                    totalQuestions: presenter.totalQuestions,
                                    percentage: percentage
                                )
                    savedToLeaderboard = true
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showSaveSuccess = true
                    }
                    
                    
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSaveSuccess = false
                        }
                    }
                    
                case .failure(let error):
                    saveError = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
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
                AnalyticsManager.shared.logDifficultyUnlocked(
                       difficulty: nextDifficulty,
                       category: presenter.selectedCategory,
                       previousScore: percentage
                   )
                   
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
