import SwiftUI

struct DifficultySelectionView: View {
    let goBack: () -> Void
    let startGame: () -> Void
    @ObservedObject var presenter: GamePresenter
    @StateObject private var unlockManager = DifficultyUnlockManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var appearAnimation = false
    @State private var showLockedAlert = false
    @State private var lockedMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.dynamicBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar - Fixed
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                goBack()
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("Trivia App")
                            .font(.headline)
                            .foregroundColor(.dynamicText)
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .opacity(0)
                    }
                    .padding()
                    .frame(height: 60)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)
                    
                    // Content Area
                    VStack(spacing: 16) {
                        // Title & Category - Compact
                        VStack(spacing: 8) {
                            Text("Choose Difficulty")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.dynamicText)
                            
                            HStack(spacing: 8) {
                                Text(presenter.selectedCategory.emoji)
                                    .font(.title3)
                                Text(presenter.selectedCategory.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.dynamicText)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                            )
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Difficulty Grid - 3x2 layout (3 rows, 2 columns)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(Array(Difficulty.allCases.enumerated()), id: \.element) { index, difficulty in
                                DifficultyCardMini(
                                    difficulty: difficulty,
                                    isSelected: presenter.selectedDifficulty == difficulty,
                                    isLocked: !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: difficulty),
                                    action: {
                                        if unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: difficulty) {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                presenter.selectedDifficulty = difficulty
                                            }
                                        } else {
                                            showLockedMessage(for: difficulty)
                                        }
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 20)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.05), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        
                        // Bottom Info & Button
                        VStack(spacing: 12) {
                            // Available Questions
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text("\(presenter.getFilteredQuestions().count) questions available")
                                    .font(.caption)
                                    .foregroundColor(.dynamicSecondaryText)
                            }
                            .opacity(appearAnimation ? 1 : 0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                            
                            // Start Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    appearAnimation = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    startGame()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.fill")
                                    Text("Start Game")
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors:
                                            (presenter.getFilteredQuestions().isEmpty ||
                                             !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty)) ?
                                            [Color.gray, Color.gray.opacity(0.8)] :
                                            [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(26)
                                .shadow(color: (presenter.getFilteredQuestions().isEmpty ||
                                                !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty)) ?
                                        Color.clear : Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(presenter.getFilteredQuestions().isEmpty ||
                                     !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty))
                            .padding(.horizontal, 30)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .onAppear {
            // Auto-select highest unlocked difficulty
            let highestUnlocked = unlockManager.getHighestUnlockedDifficulty(category: presenter.selectedCategory)
            if !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty) {
                presenter.selectedDifficulty = highestUnlocked
            }
            
            withAnimation {
                appearAnimation = true
            }
        }
        .alert("Difficulty Locked", isPresented: $showLockedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(lockedMessage)
        }
    }
    
    private func showLockedMessage(for difficulty: Difficulty) {
        let difficulties = Difficulty.allCases
        guard let index = difficulties.firstIndex(of: difficulty), index > 0 else {
            return
        }
        
        let previousDifficulty = difficulties[index - 1]
        lockedMessage = "Complete \(previousDifficulty.rawValue) level in \(presenter.selectedCategory.rawValue) to unlock \(difficulty.rawValue)!"
        showLockedAlert = true
    }
}

// MARK: - Mini Difficulty Card (Fits on one screen)
struct DifficultyCardMini: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action() // Always call action (it handles locked logic)
        }) {
            ZStack {
                VStack(spacing: 8) {
                    // Emoji Icon - Smaller
                    ZStack {
                        Circle()
                            .fill(difficulty.color.opacity(colorScheme == .dark ? 0.3 : 0.2))
                            .frame(width: 50, height: 50)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        } else {
                            Text(difficulty.emoji)
                                .font(.system(size: 24))
                        }
                    }
                    
                    // Title
                    Text(difficulty.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(isLocked ? .gray : .dynamicText)
                    
                    // Multiplier Badge - Compact
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                        Text("×\(difficulty.pointsMultiplier)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(isLocked ? .gray : difficulty.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill((isLocked ? Color.gray : difficulty.color).opacity(0.15))
                    )
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isLocked ? Color.gray.opacity(0.1) :
                              (isSelected ? difficulty.color.opacity(colorScheme == .dark ? 0.15 : 0.1) : Color.dynamicCardBackground))
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: isSelected ? 6 : 3, x: 0, y: isSelected ? 3 : 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isLocked ? Color.gray.opacity(0.3) : (isSelected ? difficulty.color : Color.clear), lineWidth: 2)
                )
                .scaleEffect(isPressed ? 0.95 : (isSelected && !isLocked ? 1.05 : 1.0))
                .grayscale(isLocked ? 1.0 : 0)
                .opacity(isLocked ? 0.5 : 1.0)
                
                // Locked overlay
                if isLocked {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.2))
                }
            }
        }
        .allowsHitTesting(true) // Always allow taps to show alert
    }
}
