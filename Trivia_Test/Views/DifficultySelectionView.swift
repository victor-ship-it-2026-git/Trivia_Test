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
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Navigation Bar
                    HStack {
                        Button(action: {
                            HapticManager.shared.selection()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                goBack()
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color.orange)
                        }
                        
                        Spacer()
                        
                        Text("Trivia Quest")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 16))
                        .opacity(0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)
                    
                    // Content Area
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Title & Category
                            VStack(spacing: 12) {
                                Text("Choose Difficulty")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 8) {
                                    Text(presenter.selectedCategory.emoji)
                                        .font(.title3)
                                    Text(presenter.selectedCategory.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.opacity(0.1))
                                )
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                            
                            // Difficulty Grid - 3x2 layout
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(Array(Difficulty.allCases.enumerated()), id: \.element) { index, difficulty in
                                    DifficultyCardModern(
                                        difficulty: difficulty,
                                        isSelected: presenter.selectedDifficulty == difficulty,
                                        isLocked: !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: difficulty),
                                        action: {
                                            if unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: difficulty) {
                                                HapticManager.shared.selection()
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                    presenter.selectedDifficulty = difficulty
                                                }
                                                
                                                AnalyticsManager.shared.logDifficultySelected(
                                                    difficulty: difficulty,
                                                    category: presenter.selectedCategory
                                                )
                                            } else {
                                                HapticManager.shared.warning()
                                                showLockedMessage(for: difficulty)
                                            }
                                        }
                                    )
                                    .opacity(appearAnimation ? 1 : 0)
                                    .offset(y: appearAnimation ? 0 : 30)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.08), value: appearAnimation)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 120) // Space for fixed button at bottom
                        }
                    }
                    
                    // Bottom Info & Button (Fixed)
                    VStack(spacing: 12) {
                        // Available Questions
                        HStack(spacing: 6) {
                                                    Image(systemName: "info.circle.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.orange)
                                                    let availableQuestions = min(presenter.getFilteredQuestions().count, 50)
                                                    Text("\(availableQuestions) questions per session")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(Color.gray)
                                                }
                                                .opacity(appearAnimation ? 1 : 0)
                                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                        
                        // Start Game Button
                        Button(action: {
                            AnalyticsManager.shared.logQuizStarted(
                                category: presenter.selectedCategory,
                                difficulty: presenter.selectedDifficulty,
                                totalQuestions: presenter.getFilteredQuestions().count
                            )
                            
                            HapticManager.shared.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                startGame()
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16))
                                Text("Start Game")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(
                                (presenter.getFilteredQuestions().isEmpty ||
                                 !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty)) ?
                                Color.gray.opacity(0.5) : .white
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                (presenter.getFilteredQuestions().isEmpty ||
                                 !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty)) ?
                                Color.gray.opacity(0.3) : Color.orange
                            )
                            .cornerRadius(16)
                        }
                        .disabled(presenter.getFilteredQuestions().isEmpty ||
                                 !unlockManager.isDifficultyAvailable(category: presenter.selectedCategory, difficulty: presenter.selectedDifficulty))
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "DifficultySelection")

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

// Modern Difficulty Card
struct DifficultyCardModern: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 10) {
                // Emoji Icon
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    } else {
                        Text(difficulty.emoji)
                            .font(.system(size: 30))
                    }
                }
                
                // Title
                Text(difficulty.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(isLocked ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                
                // Multiplier Badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                    Text("×\(difficulty.pointsMultiplier)")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(isLocked ? .gray : difficulty.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill((isLocked ? Color.gray : difficulty.color).opacity(0.15))
                )
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isLocked ? Color.gray.opacity(0.2) :
                        (isSelected ? Color.orange : Color.gray.opacity(0.2)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(isSelected && !isLocked ? 1.05 : 1.0)
            .grayscale(isLocked ? 0.8 : 0)
            .opacity(isLocked ? 0.6 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .overlay(
                // Checkmark badge for selected
                Group {
                    if isSelected && !isLocked {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 24, height: 24)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                            }
                            Spacer()
                        }
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isLocked {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
