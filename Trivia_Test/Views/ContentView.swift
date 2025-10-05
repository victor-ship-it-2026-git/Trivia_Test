//
//  ContentView.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: ViewControllerHolder {
        get { return self[ViewControllerKey.self] }
        set { self[ViewControllerKey.self] = newValue }
    }
}

struct ContentView: View {
    @StateObject private var gamePresenter = GamePresenter()
    @StateObject private var adMobManager = AdMobManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showSplash = true
    @State private var currentScreen: Screen = .home
    
    enum Screen {
        case home
        case categorySelection
        case difficultySelection
        case game
        case results
        case leaderboard
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
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
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
                    }
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
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            currentScreen = .home
                        }
                    },
                    goHome: {
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
            }
        }
    }
}
