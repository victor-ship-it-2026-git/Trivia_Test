import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var gamePresenter = GamePresenter()
    @ObservedObject private var adMobManager = AdMobManager.shared
    @StateObject private var ratingManager = RatingManager.shared
    @StateObject private var transitionCoordinator = TransitionCoordinator()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true
    @State private var currentScreen: Screen = .home
    @State private var showRatingPopup = false
    
    enum Screen {
        case home
        case categorySelection
        case difficultySelection
        case game
        case results
        case leaderboard
        case shop
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1000)
            } else if !hasSeenOnboarding {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasSeenOnboarding = true
                    }
                })
                .transition(.opacity)
                .zIndex(999)
            } else {
                mainContent
                    .zIndex(1)
            }
            
            // Rating Popup Overlay
            if showRatingPopup {
                RatingPopupView(isPresented: $showRatingPopup)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    .zIndex(2000)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSplash)
        .animation(.easeInOut(duration: 0.3), value: hasSeenOnboarding)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showRatingPopup)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
        .onChange(of: ratingManager.shouldShowRating) { oldValue, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showRatingPopup = true
                    }
                    ratingManager.shouldShowRating = false
                }
            }
        }
    }
    
    @ViewBuilder
    var mainContent: some View {
        ZStack {
            switch currentScreen {
            case .home:
                HomeView(
                    startGame: { navigateTo(.difficultySelection) },
                    showLeaderboard: { navigateTo(.leaderboard) },
                    showShop: { navigateTo(.shop) },
                    gamePresenter: gamePresenter
                )
                .transition(.opacity)
                
            case .categorySelection:
                CategorySelectionView(
                    goHome: { navigateTo(.home) },
                    goNext: { navigateTo(.difficultySelection) },
                    presenter: gamePresenter
                )
                .transition(.opacity)
                
            case .difficultySelection:
                DifficultySelectionView(
                    goBack: { navigateTo(.home) },
                    startGame: {
                        gamePresenter.resetGame()
                        navigateTo(.game)
                    },
                    presenter: gamePresenter
                )
                .transition(.opacity)
                
            case .game:
                GameView(
                    presenter: gamePresenter,
                    adMobManager: adMobManager,
                    showResults: {
                        RatingManager.shared.checkAndShowRating(difficulty: gamePresenter.selectedDifficulty)
                        navigateTo(.results)
                    },
                    goHome: { navigateTo(.home) }
                )
                .transition(.opacity)
                
            case .results:
                ResultsView(
                    presenter: gamePresenter,
                    playAgain: { navigateTo(.difficultySelection) },
                    goHome: { navigateTo(.home) },
                    showLeaderboard: { navigateTo(.leaderboard) }
                )
                .transition(.opacity)
                
            case .leaderboard:
                LeaderboardView(
                    goHome: { navigateTo(.home) }
                )
                .transition(.opacity)
                
            case .shop:
                ShopScreenView(
                    goBack: { navigateTo(.home) }
                )
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentScreen)
    }
    
    private func navigateTo(_ screen: Screen) {
        transitionCoordinator.performTransition(duration: 0.5) {
            currentScreen = screen
        }
    }
}
