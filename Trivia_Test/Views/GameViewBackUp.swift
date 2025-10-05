//
//  GameViewBackUp.swift
//  Trivia_Test
//
//  Created by Win on 8/10/2568 BE.
//

/*
import SwiftUI

struct GameView: View {
    @ObservedObject var presenter: GamePresenter
    @ObservedObject var adMobManager: AdMobManager
    let showResults: () -> Void
    let goHome: () -> Void
    @Environment(\.viewController) var viewControllerHolder: ViewControllerHolder
    @Environment(\.colorScheme) var colorScheme
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @State private var showQuestion = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ?
                        [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                        [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Streak
                    headerSection
                        .frame(height: 80)
                    
                    // Lifeline Panel
                    LifelinePanel(presenter: presenter, onUseLifeline: handleLifelineUse)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Progress Info
                    progressSection
                        .frame(height: 35)
                        .padding(.horizontal)
                    
                    // Timer Progress Bar
                    timerProgressBar
                        .frame(height: 16)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Question Card
                    questionCard
                        .frame(maxHeight: geometry.size.height * 0.5)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    
                    Spacer(minLength: 0)
                    
                    // Bottom Action Area
                    bottomActionArea
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                }
                
                // Bonus Points Animation
                if presenter.bonusPoints > 10 {
                    VStack {
                        Spacer()
                            .frame(height: geometry.size.height * 0.3)
                        
                        BonusPointsAnimation(
                            points: presenter.bonusPoints,
                            multiplier: presenter.streak.multiplier
                        )
                        
                        Spacer()
                    }
                }
                
                // Streak Animation
                if presenter.showStreakAnimation {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text(presenter.streak.emoji)
                                .font(.system(size: 100))
                                .scaleEffect(1.5)
                                .animation(.spring(response: 0.5), value: presenter.showStreakAnimation)
                            
                            Text("STREAK!")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("×\(presenter.streak.multiplier) Multiplier!")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation { showQuestion = true }
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                stopTimer()
                goHome()
            }) {
                Image(systemName: "house.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Circle().fill(Color.dynamicCardBackground))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2)
            }
            
            StreakDisplay(streak: presenter.streak, showAnimation: presenter.showStreakAnimation)
            
            Spacer()
            
            // Timer
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.title3)
                Text("\(timeRemaining)s")
                    .font(.title3)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            .foregroundColor(timeRemaining <= 10 ? .red : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill((timeRemaining <= 10 ? Color.red : Color.blue).opacity(colorScheme == .dark ? 0.25 : 0.15))
            )
            .overlay(
                Capsule()
                    .stroke(timeRemaining <= 10 ? Color.red : Color.blue, lineWidth: 2)
            )
            .scaleEffect(timeRemaining <= 5 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3).repeatCount(timeRemaining <= 5 ? 10 : 1), value: timeRemaining)
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
                Text("Score")
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
                Text("\(presenter.score)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.dynamicText)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 2)
            )
        }
        .padding(.horizontal)
    }
    
    private var progressSection: some View {
        HStack {
            Text("Q \(presenter.currentQuestionIndex + 1)/\(presenter.questions.count)")
                .font(.subheadline)
                .foregroundColor(.dynamicSecondaryText)
            
            Spacer()
            
            HStack(spacing: 6) {
                Text(presenter.currentQuestion.category.emoji)
                    .font(.caption)
                Text(presenter.currentQuestion.category.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.dynamicText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
            .cornerRadius(10)
            
            Circle()
                .fill(presenter.currentQuestion.difficulty.color)
                .frame(width: 10, height: 10)
        }
    }
    
    private var timerProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: timeRemaining <= 10 ?
                                [Color.red, Color.orange] : [Color.blue, Color.cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (Double(timeRemaining) / 30.0), height: 6)
                    .animation(.linear(duration: 1), value: timeRemaining)
            }
        }
        .frame(height: 6)
    }
    
    private var questionCard: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(presenter.currentQuestion.text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.dynamicText)
                    .padding(.top)
                    .opacity(showQuestion ? 1 : 0)
                    .offset(y: showQuestion ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showQuestion)
                
                VStack(spacing: 10) {
                    ForEach(0..<presenter.currentQuestion.options.count, id: \.self) { index in
                        if !presenter.hiddenOptions.contains(index) {
                            OptionButtonAnimated(
                                text: presenter.currentQuestion.options[index],
                                isSelected: presenter.selectedAnswer == index,
                                isCorrect: presenter.showingAnswer && index == presenter.currentQuestion.correctAnswer,
                                isWrong: presenter.showingAnswer && presenter.selectedAnswer == index && index != presenter.currentQuestion.correctAnswer,
                                isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        presenter.selectAnswer(index)
                                    }
                                    stopTimer()
                                }
                            )
                            .opacity(showQuestion ? 1 : 0)
                            .offset(x: showQuestion ? 0 : -20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showQuestion)
                        }
                    }
                }
                .padding(.bottom)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private var bottomActionArea: some View {
        ZStack {
            Color.dynamicCardBackground
                .opacity(colorScheme == .dark ? 1.0 : 0.95)
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                if presenter.needsToWatchAd {
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: presenter.timeExpired ? "clock.badge.xmark" : "xmark.circle.fill")
                                .font(.title3)
                            Text(presenter.timeExpired ? "Time's Up!" : "Wrong Answer!")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.red)
                        
                        Button(action: {
                            if let vc = viewControllerHolder.value {
                                adMobManager.onAdRewarded = {
                                    withAnimation {
                                        presenter.needsToWatchAd = false
                                        presenter.showingAnswer = false
                                        presenter.selectedAnswer = nil
                                        presenter.timeExpired = false
                                    }
                                    resetTimer()
                                }
                                adMobManager.showAd(from: vc)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.rectangle.fill")
                                Text(adMobManager.isAdReady ? "Watch Ad to Continue" : "Loading...")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(adMobManager.isAdReady ?
                                        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing) :
                                        LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)
                                    )
                            )
                            .shadow(color: adMobManager.isAdReady ? Color.red.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!adMobManager.isAdReady)
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 16)
                } else if presenter.showingAnswer {
                    Button(action: {
                        withAnimation { showQuestion = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if presenter.isLastQuestion {
                                stopTimer()
                                presenter.finalizeGameCoins()
                                showResults()
                            } else {
                                presenter.nextQuestion()
                                resetTimer()
                                withAnimation { showQuestion = true }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(presenter.isLastQuestion ? "See Results" : "Next Question")
                                .fontWeight(.semibold)
                            Image(systemName: presenter.isLastQuestion ? "flag.checkered" : "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    // MARK: - Lifeline Handlers
    private func handleLifelineUse(_ type: LifelineType) {
        switch type {
        case .fiftyFifty:
            _ = presenter.useFiftyFifty()
            
        case .skip:
            if presenter.useSkip() {
                withAnimation { showQuestion = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    resetTimer()
                    withAnimation { showQuestion = true }
                }
            }
            
        case .extraTime:
            if presenter.useExtraTime() {
                timeRemaining = min(timeRemaining + 15, 45)
            }
        }
    }
    
    // MARK: - Timer Functions
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !presenter.showingAnswer && !presenter.needsToWatchAd {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    handleTimeExpired()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        startTimer()
    }
    
    private func handleTimeExpired() {
        stopTimer()
        withAnimation {
            presenter.handleTimeExpired()
        }
    }
}
*/
