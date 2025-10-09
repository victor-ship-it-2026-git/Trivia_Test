//
//  ContentView.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var gamePresenter = GamePresenter()
    @ObservedObject private var adMobManager = AdMobManager.shared
    @StateObject private var ratingManager = RatingManager.shared
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
            } else if !hasSeenOnboarding {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        hasSeenOnboarding = true
                    }
                })
                .transition(.opacity)
            } else {
                mainContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
            
            // Rating Popup Overlay
            if showRatingPopup {
                RatingPopupView(isPresented: $showRatingPopup)
                    .transition(.opacity)
                    .zIndex(1000)
            }
        }
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
                    startGame: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .difficultySelection
                        }
                    },
                    showLeaderboard: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .leaderboard
                        }
                    },
                    showShop: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .shop
                        }
                    },
                    gamePresenter: gamePresenter
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
            case .categorySelection:
                CategorySelectionView(
                    goHome: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    },
                    goNext: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .difficultySelection
                        }
                    },
                    presenter: gamePresenter
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
            case .difficultySelection:
                DifficultySelectionView(
                    goBack: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    },
                    startGame: {
                        gamePresenter.resetGame()
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .game
                        }
                    },
                    presenter: gamePresenter
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
            case .game:
                GameView(
                    presenter: gamePresenter,
                    adMobManager: adMobManager,
                    showResults: {
                        // Check and show rating when moving to results
                        RatingManager.shared.checkAndShowRating(difficulty: gamePresenter.selectedDifficulty)
                        
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .results
                        }
                    },
                    goHome: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 1.1).combined(with: .opacity)
                ))
                
            case .results:
                ResultsView(
                    presenter: gamePresenter,
                    playAgain: {
                        // Keep the current category, just go back to difficulty selection
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .difficultySelection
                        }
                    },
                    goHome: {
                        // Reset to home (category selection)
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    },
                    showLeaderboard: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .leaderboard
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                
            case .leaderboard:
                LeaderboardView(
                    goHome: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                
            case .shop:
                ShopScreenView(
                    goBack: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
    }
}
