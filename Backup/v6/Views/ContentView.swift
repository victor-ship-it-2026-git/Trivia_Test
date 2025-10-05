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
                    hasSeenOnboarding = true
                })
                .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
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
        switch currentScreen {
        case .home:
            HomeView(
                startGame: { currentScreen = .categorySelection },
                showLeaderboard: { currentScreen = .leaderboard }
            )
        case .categorySelection:
            CategorySelectionView(
                goHome: { currentScreen = .home },
                goNext: { currentScreen = .difficultySelection },
                presenter: gamePresenter
            )
        case .difficultySelection:
            DifficultySelectionView(
                goBack: { currentScreen = .categorySelection },
                startGame: {
                    gamePresenter.resetGame()
                    currentScreen = .game
                },
                presenter: gamePresenter
            )
        case .game:
            GameView(
                presenter: gamePresenter,
                adMobManager: adMobManager,
                showResults: { currentScreen = .results },
                goHome: { currentScreen = .home }
            )
        case .results:
            ResultsView(
                presenter: gamePresenter,
                playAgain: { currentScreen = .categorySelection },
                goHome: { currentScreen = .home },
                showLeaderboard: { currentScreen = .leaderboard }
            )
        case .leaderboard:
            LeaderboardView(goHome: { currentScreen = .home })
        }
    }
}
