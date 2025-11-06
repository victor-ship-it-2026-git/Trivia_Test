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
    @State private var isNavigating = false
    @State private var appearAnimation = false
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
        case 50..<70: return "Good Effort! 💪"
        default: return "Keep Practicing! 💪"
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
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isNavigating)
                    
                    Spacer()
                    
                    Button(action: {
                        guard !isNavigating else { return }
                        handleLeaderboardNavigation()
                    }) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .frame(width: 44, height: 44)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    }
                    .disabled(isNavigating)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .opacity(appearAnimation && !isNavigating ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appearAnimation)
                .animation(.easeOut(duration: 0.2), value: isNavigating)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Success Icon
                        ZStack {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "medal.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 12)
                        .opacity(appearAnimation ? 1 : 0)
                        .scaleEffect(appearAnimation ? 1 : 0.5)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appearAnimation)
                        
                        // Title
                        Text("\(presenter.selectedDifficulty.rawValue) - \(presenter.selectedCategory.rawValue) Passed!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
                        
                        // Stats Cards
                        HStack(spacing: 16) {
                            // Points Earned
                            VStack(spacing: 8) {
                                Text("Points Earned")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.gray)
                                
                                Text("\(presenter.score)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color.purple)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: appearAnimation)
                            
                            // Current Streaks
                            VStack(spacing: 8) {
                                Text("Current Streaks")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.gray)
                                
                                VStack(spacing: 2) {
                                    Text("\(presenter.streak.currentStreak)")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(Color.yellow)
                                    
                                    Text("Streaks")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color.yellow)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 110)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 30)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appearAnimation)
                        }
                        .padding(.horizontal, 16)
                        
                        // Unlock notification
                        if let unlocked = unlockedDifficulty, showUnlockAnimation {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Text(unlocked.emoji)
                                        .font(.system(size: 24))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("NEW")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.purple)
                                    
                                    Text("\(unlocked.rawValue) Difficulty Unlocked")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 16)
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
                            .padding(.horizontal, 16)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Play Now (if unlocked)
                            if unlockedDifficulty != nil && showUnlockAnimation {
                                Button(action: {
                                    guard !isNavigating else { return }
                                    handlePlayAgain()
                                }) {
                                    Text("Play Now")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(Color.purple)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(Color.purple.opacity(0.15))
                                        .cornerRadius(16)
                                }
                                .disabled(isNavigating)
                                .opacity(appearAnimation ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: appearAnimation)
                            }
                            
                            // Save to Leaderboard
                            if !savedToLeaderboard {
                                Button(action: { showNameInput = true }) {
                                    HStack {
                                        if isSavingToFirebase {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text("Claim Your Spot")
                                                .font(.system(size: 17, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.purple)
                                    .cornerRadius(16)
                                }
                                .disabled(isSavingToFirebase || isNavigating)
                                .opacity(appearAnimation ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appearAnimation)
                            }
                            
                            // Next Difficulty
                            Button(action: {
                                guard !isNavigating else { return }
                                handlePlayAgain()
                            }) {
                                Text("Next Difficulty")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.blue)
                                    .cornerRadius(16)
                            }
                            .disabled(isNavigating)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                            
                            // Share Score
                            Button(action: shareAchievement) {
                                HStack(spacing: 8) {
                                    if isGeneratingShare {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Share Score")
                                            .font(.system(size: 17, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.orange)
                                .cornerRadius(16)
                            }
                            .disabled(isGeneratingShare || isNavigating)
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .disabled(isNavigating)
            }
            
            // Fade overlay during navigation
            if isNavigating {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                    .transition(.opacity)
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
            
            isNavigating = false
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            
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
    
    private func handleHomeNavigation() {
        HapticManager.shared.selection()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isNavigating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            goHome()
        }
    }
    
    private func handleLeaderboardNavigation() {
        HapticManager.shared.selection()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isNavigating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showLeaderboard()
        }
    }
    
    private func handlePlayAgain() {
        HapticManager.shared.selection()
        
        withAnimation(.easeOut(duration: 0.2)) {
            isNavigating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            playAgain()
        }
    }
    
    // Share Achievement
    func shareAchievement() {
        AnalyticsManager.shared.logShareInitiated(
            shareType: "results",
            category: presenter.selectedCategory,
            difficulty: presenter.selectedDifficulty,
            score: presenter.score
        )
        
        isGeneratingShare = true
        HapticManager.shared.success()
        
        let name = playerName.isEmpty ? "Player" : playerName
        
        let shareCard = ResultsShareCard(
            score: presenter.score,
            totalQuestions: presenter.totalQuestions,
            category: presenter.selectedCategory.rawValue,
            difficulty: presenter.selectedDifficulty.rawValue,
            playerName: name
        )
        
        Task { @MainActor in
            if let image = ShareManager.shared.generateShareImage(from: AnyView(shareCard)) {
                let shareText = ShareManager.shared.generateShareText(
                    score: presenter.score,
                    total: presenter.totalQuestions,
                    category: presenter.selectedCategory.rawValue,
                    difficulty: presenter.selectedDifficulty.rawValue
                )
                
                isGeneratingShare = false
                
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
        
        let finalPlayerName = playerName.isEmpty ? "Anonymous" : playerName
        
        // Save player name for leaderboard identification
        UserDefaults.standard.set(finalPlayerName, forKey: "LastSavedPlayerName")
        
        let entry = LeaderboardEntry(
            id: UUID(),
            playerName: finalPlayerName,
            score: presenter.score,
            totalQuestions: presenter.totalQuestions,
            category: presenter.selectedCategory.rawValue,
            difficulty: presenter.selectedDifficulty.rawValue,
            date: Date()
        )
        
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
        if percentage >= 70 {
            let difficulties = Difficulty.allCases
            guard let currentIndex = difficulties.firstIndex(of: presenter.selectedDifficulty),
                  currentIndex < difficulties.count - 1 else {
                return
            }
            
            let nextDifficulty = difficulties[currentIndex + 1]
            
            if !unlockManager.isDifficultyUnlocked(category: presenter.selectedCategory, difficulty: nextDifficulty) {
                unlockManager.unlockNextDifficulty(category: presenter.selectedCategory, completedDifficulty: presenter.selectedDifficulty)
                AnalyticsManager.shared.logDifficultyUnlocked(
                    difficulty: nextDifficulty,
                    category: presenter.selectedCategory,
                    previousScore: percentage
                )
                
                unlockedDifficulty = nextDifficulty
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showUnlockAnimation = true
                    }
                }
            }
        }
    }
}
