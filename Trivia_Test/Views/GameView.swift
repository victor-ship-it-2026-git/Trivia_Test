<<<<<<< HEAD
=======
<<<<<<< HEAD

=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
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
<<<<<<< HEAD
    @State private var pulseTimer = false
    @State private var confettiTrigger = 0
    @State private var shakeEffect = false
=======
<<<<<<< HEAD
=======
    @State private var pulseTimer = false
    @State private var confettiTrigger = 0
    @State private var shakeEffect = false
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
<<<<<<< HEAD
                // Animated Background
                AnimatedBackground(isCorrect: presenter.showingAnswer && presenter.selectedAnswer == presenter.currentQuestion.correctAnswer)
                    .ignoresSafeArea()
=======
<<<<<<< HEAD
                // Background
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark ?
                        [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                        [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
>>>>>>> d8765c0 (Resolve merge)
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernGameHeader(
                        presenter: presenter,
                        timeRemaining: timeRemaining,
                        pulseTimer: pulseTimer,
                        goHome: {
                            stopTimer()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                goHome()
                            }
                        }
                    )
                    .frame(height: 100)
                    .padding(.horizontal)
                    
                    // Progress Bar
                    GameProgressBar(
                        currentQuestion: presenter.currentQuestionIndex + 1,
                        totalQuestions: presenter.questions.count
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Timer Progress
                    TimerProgressBar(timeRemaining: timeRemaining)
                        .frame(height: 8)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    // Question Card
                    ModernQuestionCard(
                        presenter: presenter,
                        showQuestion: showQuestion,
                        shakeEffect: shakeEffect,
                        onAnswerSelected: { index in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                presenter.selectAnswer(index)
                            }
                            stopTimer()
                            
                            // Trigger effects
                            if index == presenter.currentQuestion.correctAnswer {
                                triggerConfetti()
                            } else {
                                triggerShake()
                            }
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 20)
                    
                    // Lifeline Panel
                    ModernLifelinePanel(
                        presenter: presenter,
                        onUseLifeline: handleLifelineUse
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    // Bottom Action Area
<<<<<<< HEAD
=======
                    bottomActionArea
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
=======
                // Animated Background
                AnimatedBackground(isCorrect: presenter.showingAnswer && presenter.selectedAnswer == presenter.currentQuestion.correctAnswer)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Modern Header
                    ModernGameHeader(
                        presenter: presenter,
                        timeRemaining: timeRemaining,
                        pulseTimer: pulseTimer,
                        goHome: {
                            stopTimer()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                goHome()
                            }
                        }
                    )
                    .frame(height: 100)
                    .padding(.horizontal)
                    
                    // Progress Bar
                    GameProgressBar(
                        currentQuestion: presenter.currentQuestionIndex + 1,
                        totalQuestions: presenter.questions.count
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Timer Progress
                    TimerProgressBar(timeRemaining: timeRemaining)
                        .frame(height: 8)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    
                    // Question Card
                    ModernQuestionCard(
                        presenter: presenter,
                        showQuestion: showQuestion,
                        shakeEffect: shakeEffect,
                        onAnswerSelected: { index in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                presenter.selectAnswer(index)
                            }
                            stopTimer()
                            
                            // Trigger effects
                            if index == presenter.currentQuestion.correctAnswer {
                                triggerConfetti()
                            } else {
                                triggerShake()
                            }
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    Spacer(minLength: 20)
                    
                    // Lifeline Panel
                    ModernLifelinePanel(
                        presenter: presenter,
                        onUseLifeline: handleLifelineUse
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    // Bottom Action Area
>>>>>>> d8765c0 (Resolve merge)
                    BottomActionArea(
                        presenter: presenter,
                        adMobManager: adMobManager,
                        viewControllerHolder: viewControllerHolder,
                        onNextQuestion: {
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
                        },
                        resetTimer: resetTimer
                    )
                    .frame(height: 140)
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
                }
                
                // Bonus Points Animation
                if presenter.bonusPoints > 10 {
<<<<<<< HEAD
                    BonusPointsFloating(
                        points: presenter.bonusPoints,
                        multiplier: presenter.streak.multiplier
                    )
                    .transition(.scale.combined(with: .opacity))
=======
<<<<<<< HEAD
                    VStack {
                        Spacer()
                            .frame(height: geometry.size.height * 0.3)
                        
                        BonusPointsAnimation(
                            points: presenter.bonusPoints,
                            multiplier: presenter.streak.multiplier
                        )
                        
                        Spacer()
                    }
>>>>>>> d8765c0 (Resolve merge)
                }
                
                // Streak Animation Overlay
                if presenter.showStreakAnimation {
<<<<<<< HEAD
=======
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
=======
                    BonusPointsFloating(
                        points: presenter.bonusPoints,
                        multiplier: presenter.streak.multiplier
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Streak Animation Overlay
                if presenter.showStreakAnimation {
>>>>>>> d8765c0 (Resolve merge)
                    StreakCelebration(streak: presenter.streak)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Confetti Effect
                if confettiTrigger > 0 {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                if presenter.streak.currentStreak >= 5 {
                    ParticleEffect(type: .star)
                        .allowsHitTesting(false)
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
                }
            }
        }
        .onAppear {
<<<<<<< HEAD
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showQuestion = true
            }
=======
<<<<<<< HEAD
            withAnimation { showQuestion = true }
=======
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showQuestion = true
            }
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
<<<<<<< HEAD
    // MARK: - Timer Functions
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !presenter.showingAnswer && !presenter.needsToWatchAd {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if timeRemaining <= 10 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            pulseTimer.toggle()
                        }
                    }
                } else {
                    handleTimeExpired()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        pulseTimer = false
    }
    
    private func resetTimer() {
        stopTimer()
        startTimer()
    }
    
    private func handleTimeExpired() {
        stopTimer()
        triggerShake()
        withAnimation {
            presenter.handleTimeExpired()
        }
    }
    
    // MARK: - Lifeline Handler
    private func handleLifelineUse(_ type: LifelineType) {
        switch type {
        case .fiftyFifty:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                _ = presenter.useFiftyFifty()
            }
            
=======
<<<<<<< HEAD
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
=======
    // MARK: - Timer Functions
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !presenter.showingAnswer && !presenter.needsToWatchAd {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    if timeRemaining <= 10 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            pulseTimer.toggle()
                        }
                    }
                } else {
                    handleTimeExpired()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        pulseTimer = false
    }
    
    private func resetTimer() {
        stopTimer()
        startTimer()
    }
    
    private func handleTimeExpired() {
        stopTimer()
        triggerShake()
        withAnimation {
            presenter.handleTimeExpired()
        }
    }
    
    // MARK: - Lifeline Handler
    private func handleLifelineUse(_ type: LifelineType) {
        switch type {
        case .fiftyFifty:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                _ = presenter.useFiftyFifty()
            }
            
>>>>>>> d8765c0 (Resolve merge)
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
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    timeRemaining = min(timeRemaining + 15, 45)
                }
            }
        }
    }
    
    // MARK: - Effect Triggers
    private func triggerConfetti() {
        confettiTrigger += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            confettiTrigger = max(0, confettiTrigger - 1)
        }
    }
    
    private func triggerShake() {
        withAnimation(.default.repeatCount(3).speed(3)) {
            shakeEffect.toggle()
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    let isCorrect: Bool
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
            
            if isCorrect {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.3),
                        Color.cyan.opacity(0.2),
                        Color.blue.opacity(0.1)
                    ]),
                    startPoint: animate ? .topLeading : .bottomTrailing,
                    endPoint: animate ? .bottomTrailing : .topLeading
                )
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                .onAppear { animate = true }
            }
        }
    }
}

// MARK: - Modern Game Header
struct ModernGameHeader: View {
    @ObservedObject var presenter: GamePresenter
    let timeRemaining: Int
    let pulseTimer: Bool
    let goHome: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Home Button
            Button(action: goHome) {
                ZStack {
                    Circle()
                        .fill(Color.dynamicCardBackground)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                    
                    Image(systemName: "house.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            // Streak Display (Compact)
            if presenter.streak.currentStreak > 0 {
                HStack(spacing: 6) {
                    Text(presenter.streak.emoji)
                        .font(.title3)
                    Text("\(presenter.streak.currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    if presenter.streak.multiplier > 1 {
                        Text("×\(presenter.streak.multiplier)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(colorScheme == .dark ? 0.2 : 0.15))
                )
            }
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
            
            Spacer()
            
            // Timer
<<<<<<< HEAD
            HStack(spacing: 8) {
                Image(systemName: timeRemaining <= 10 ? "clock.badge.exclamationmark.fill" : "clock.fill")
=======
<<<<<<< HEAD
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
=======
            HStack(spacing: 8) {
                Image(systemName: timeRemaining <= 10 ? "clock.badge.exclamationmark.fill" : "clock.fill")
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
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
<<<<<<< HEAD
            .scaleEffect(pulseTimer ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: pulseTimer)
=======
<<<<<<< HEAD
            .overlay(
                Capsule()
                    .stroke(timeRemaining <= 10 ? Color.red : Color.blue, lineWidth: 2)
            )
            .scaleEffect(timeRemaining <= 5 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3).repeatCount(timeRemaining <= 5 ? 10 : 1), value: timeRemaining)
=======
            .scaleEffect(pulseTimer ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: pulseTimer)
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
            
            Spacer()
            
            // Score
            VStack(spacing: 2) {
<<<<<<< HEAD
=======
<<<<<<< HEAD
                Text("Score")
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
>>>>>>> d8765c0 (Resolve merge)
                Text("\(presenter.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.dynamicText)
                Text("pts")
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
            )
        }
    }
}

// MARK: - Game Progress Bar
struct GameProgressBar: View {
    let currentQuestion: Int
    let totalQuestions: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.dynamicText)
                Spacer()
                Text("\(Int((Double(currentQuestion) / Double(totalQuestions)) * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(currentQuestion) / Double(totalQuestions)), height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentQuestion)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Timer Progress Bar
struct TimerProgressBar: View {
    let timeRemaining: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
<<<<<<< HEAD
                    .fill(Color.gray.opacity(0.2))
=======
                    .fill(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
                    .frame(height: 6)
=======
                Text("\(presenter.score)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.dynamicText)
                Text("pts")
                    .font(.caption2)
                    .foregroundColor(.dynamicSecondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
            )
        }
    }
}

// MARK: - Game Progress Bar
struct GameProgressBar: View {
    let currentQuestion: Int
    let totalQuestions: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestion) of \(totalQuestions)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.dynamicText)
                Spacer()
                Text("\(Int((Double(currentQuestion) / Double(totalQuestions)) * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (Double(currentQuestion) / Double(totalQuestions)), height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentQuestion)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Timer Progress Bar
struct TimerProgressBar: View {
    let timeRemaining: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: timeRemaining <= 10 ?
                                [Color.red, Color.orange] : [Color.blue, Color.cyan]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
<<<<<<< HEAD
                    .frame(width: geometry.size.width * (Double(timeRemaining) / 30.0))
=======
<<<<<<< HEAD
                    .frame(width: geometry.size.width * (Double(timeRemaining) / 30.0), height: 6)
>>>>>>> d8765c0 (Resolve merge)
                    .animation(.linear(duration: 1), value: timeRemaining)
            }
        }
    }
}

// MARK: - Modern Question Card
struct ModernQuestionCard: View {
    @ObservedObject var presenter: GamePresenter
    let showQuestion: Bool
    let shakeEffect: Bool
    let onAnswerSelected: (Int) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Category Badge
            HStack(spacing: 8) {
                Text(presenter.currentQuestion.category.emoji)
                    .font(.title3)
                Text(presenter.currentQuestion.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Circle()
                    .fill(presenter.currentQuestion.difficulty.color)
                    .frame(width: 12, height: 12)
                Text(presenter.currentQuestion.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(presenter.currentQuestion.difficulty.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.dynamicCardBackground.opacity(0.5))
            )
            .opacity(showQuestion ? 1 : 0)
            .offset(y: showQuestion ? 0 : -20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showQuestion)
            
            // Question Text
            ScrollView {
                Text(presenter.currentQuestion.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.dynamicText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .opacity(showQuestion ? 1 : 0)
                    .offset(y: showQuestion ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showQuestion)
                    .modifier(ShakeEffect(shakes: shakeEffect ? 3 : 0))
            }
            .frame(maxHeight: 120)
            
            // Answer Options
            VStack(spacing: 12) {
                ForEach(0..<presenter.currentQuestion.options.count, id: \.self) { index in
                    if !presenter.hiddenOptions.contains(index) {
                        ModernOptionButton(
                            text: presenter.currentQuestion.options[index],
                            index: index,
                            isSelected: presenter.selectedAnswer == index,
                            isCorrect: presenter.showingAnswer && index == presenter.currentQuestion.correctAnswer,
                            isWrong: presenter.showingAnswer && presenter.selectedAnswer == index && index != presenter.currentQuestion.correctAnswer,
                            isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                            action: { onAnswerSelected(index) }
                        )
                        .opacity(showQuestion ? 1 : 0)
                        .offset(x: showQuestion ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.1), value: showQuestion)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Modern Option Button
struct ModernOptionButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
<<<<<<< HEAD
=======
    private var bottomActionArea: some View {
=======
                    .frame(width: geometry.size.width * (Double(timeRemaining) / 30.0))
                    .animation(.linear(duration: 1), value: timeRemaining)
            }
        }
    }
}

// MARK: - Modern Question Card
struct ModernQuestionCard: View {
    @ObservedObject var presenter: GamePresenter
    let showQuestion: Bool
    let shakeEffect: Bool
    let onAnswerSelected: (Int) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 20) {
            // Category Badge
            HStack(spacing: 8) {
                Text(presenter.currentQuestion.category.emoji)
                    .font(.title3)
                Text(presenter.currentQuestion.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Circle()
                    .fill(presenter.currentQuestion.difficulty.color)
                    .frame(width: 12, height: 12)
                Text(presenter.currentQuestion.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(presenter.currentQuestion.difficulty.color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.dynamicCardBackground.opacity(0.5))
            )
            .opacity(showQuestion ? 1 : 0)
            .offset(y: showQuestion ? 0 : -20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showQuestion)
            
            // Question Text
            ScrollView {
                Text(presenter.currentQuestion.text)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.dynamicText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .opacity(showQuestion ? 1 : 0)
                    .offset(y: showQuestion ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showQuestion)
                    .modifier(ShakeEffect(shakes: shakeEffect ? 3 : 0))
            }
            .frame(maxHeight: 120)
            
            // Answer Options
            VStack(spacing: 12) {
                ForEach(0..<presenter.currentQuestion.options.count, id: \.self) { index in
                    if !presenter.hiddenOptions.contains(index) {
                        ModernOptionButton(
                            text: presenter.currentQuestion.options[index],
                            index: index,
                            isSelected: presenter.selectedAnswer == index,
                            isCorrect: presenter.showingAnswer && index == presenter.currentQuestion.correctAnswer,
                            isWrong: presenter.showingAnswer && presenter.selectedAnswer == index && index != presenter.currentQuestion.correctAnswer,
                            isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                            action: { onAnswerSelected(index) }
                        )
                        .opacity(showQuestion ? 1 : 0)
                        .offset(x: showQuestion ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.1), value: showQuestion)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 12, x: 0, y: 6)
        )
    }
}

// MARK: - Modern Option Button
struct ModernOptionButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
>>>>>>> d8765c0 (Resolve merge)
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(colorScheme == .dark ? 0.3 : 0.2)
        } else if isWrong {
            return Color.red.opacity(colorScheme == .dark ? 0.3 : 0.2)
        } else if isSelected {
            return Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15)
        } else {
            return Color.dynamicCardBackground
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color.blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                isPressed = false
            }
        }) {
            HStack(spacing: 12) {
                // Option Letter
                Text(optionLetter(index))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                isCorrect ? Color.green :
                                isWrong ? Color.red :
                                isSelected ? Color.blue :
                                Color.gray.opacity(0.5)
                            )
                    )
                
                Text(text)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(.dynamicText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isSelected || isCorrect || isWrong ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .disabled(isDisabled)
        .opacity(isDisabled && !isCorrect && !isWrong ? 0.6 : 1.0)
    }
    
    private func optionLetter(_ index: Int) -> String {
        return ["A", "B", "C", "D"][index]
    }
}

// MARK: - Modern Lifeline Panel
struct ModernLifelinePanel: View {
    @ObservedObject var presenter: GamePresenter
    let onUseLifeline: (LifelineType) -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(LifelineType.allCases, id: \.self) { type in
                ModernLifelineButton(
                    lifeline: type,
                    quantity: presenter.getLifelineQuantity(type),
                    isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                    action: { onUseLifeline(type) }
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dynamicCardBackground.opacity(colorScheme == .dark ? 0.8 : 0.95))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8)
        )
    }
}

// MARK: - Modern Lifeline Button
struct ModernLifelineButton: View {
    let lifeline: LifelineType
    let quantity: Int
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var iconColor: Color {
        switch lifeline {
        case .fiftyFifty: return .blue
        case .skip: return .orange
        case .extraTime: return .green
        }
    }
    
    var body: some View {
        Button(action: {
            guard quantity > 0 && !isDisabled else { return }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(quantity > 0 && !isDisabled ? 0.2 : 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: lifeline.icon)
                        .font(.title2)
                        .foregroundColor(quantity > 0 && !isDisabled ? iconColor : .gray)
                    
                    if quantity > 0 {
                        Text("\(quantity)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(iconColor))
                            .offset(x: 20, y: -20)
                    }
                }
                
                Text(lifeline.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(quantity > 0 && !isDisabled ? .dynamicText : .gray)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .disabled(isDisabled || quantity == 0)
        .opacity(quantity == 0 ? 0.5 : 1.0)
    }
}

// MARK: - Bottom Action Area
struct BottomActionArea: View {
    @ObservedObject var presenter: GamePresenter
    @ObservedObject var adMobManager: AdMobManager
    let viewControllerHolder: ViewControllerHolder
    let onNextQuestion: () -> Void
    let resetTimer: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
        ZStack {
            Color.dynamicCardBackground
                .opacity(colorScheme == .dark ? 1.0 : 0.95)
                .ignoresSafeArea(edges: .bottom)
            
<<<<<<< HEAD
            VStack(spacing: 16) {
                if presenter.needsToWatchAd {
=======
<<<<<<< HEAD
            VStack(spacing: 0) {
                if presenter.needsToWatchAd {
                    VStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: presenter.timeExpired ? "clock.badge.xmark" : "xmark.circle.fill")
                                .font(.title3)
=======
            VStack(spacing: 16) {
                if presenter.needsToWatchAd {
>>>>>>> d8765c0 (Resolve merge)
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: presenter.timeExpired ? "clock.badge.xmark.fill" : "xmark.circle.fill")
                                .font(.title2)
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
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
<<<<<<< HEAD
                            HStack(spacing: 10) {
=======
<<<<<<< HEAD
                            HStack(spacing: 8) {
>>>>>>> d8765c0 (Resolve merge)
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title3)
                                Text(adMobManager.isAdReady ? "Watch Ad to Continue" : "Loading Ad...")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: adMobManager.isAdReady ?
                                                [Color.red, Color.orange] :
                                                [Color.gray, Color.gray.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: adMobManager.isAdReady ? Color.red.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!adMobManager.isAdReady)
                    }
                    .padding(.horizontal, 20)
                } else if presenter.showingAnswer {
                    Button(action: onNextQuestion) {
                        HStack(spacing: 10) {
                            Text(presenter.isLastQuestion ? "See Results" : "Next Question")
                                .fontWeight(.semibold)
                            Image(systemName: presenter.isLastQuestion ? "flag.checkered" : "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
        }
    }
}
<<<<<<< HEAD
=======
=======
                            HStack(spacing: 10) {
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title3)
                                Text(adMobManager.isAdReady ? "Watch Ad to Continue" : "Loading Ad...")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: adMobManager.isAdReady ?
                                                [Color.red, Color.orange] :
                                                [Color.gray, Color.gray.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: adMobManager.isAdReady ? Color.red.opacity(0.4) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!adMobManager.isAdReady)
                    }
                    .padding(.horizontal, 20)
                } else if presenter.showingAnswer {
                    Button(action: onNextQuestion) {
                        HStack(spacing: 10) {
                            Text(presenter.isLastQuestion ? "See Results" : "Next Question")
                                .fontWeight(.semibold)
                            Image(systemName: presenter.isLastQuestion ? "flag.checkered" : "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 16)
        }
    }
}
>>>>>>> d8765c0 (Resolve merge)

// MARK: - Bonus Points Floating Animation
struct BonusPointsFloating: View {
    let points: Int
    let multiplier: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 8) {
            Text("+\(points)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.green)
            
            if multiplier > 1 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("×\(multiplier) Streak!")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
        }
        .scaleEffect(scale)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.2
            }
            withAnimation(.easeOut(duration: 2.0)) {
                offset = -100
                opacity = 0
            }
        }
    }
}

// MARK: - Streak Celebration
struct StreakCelebration: View {
    let streak: Streak
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -15
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(streak.emoji)
                    .font(.system(size: 120))
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                
                VStack(spacing: 12) {
                    Text("STREAK!")
                        .font(.system(size: 56, weight: .black))
                        .foregroundColor(.white)
                    
                    Text("×\(streak.multiplier) Points Multiplier")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange, lineWidth: 2)
                                                                        )
                                                                )
                                                        }
                                                    }
                                                    .scaleEffect(scale)
                                                }
                                                .onAppear {
                                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                                                        scale = 1.0
                                                        rotation = 0
                                                    }
                                                }
                                            }
                                        }

                                        // MARK: - Confetti View
                                        struct ConfettiView: View {
                                            @State private var confettiPieces: [ConfettiPiece] = []
                                            
                                            var body: some View {
                                                GeometryReader { geometry in
                                                    ZStack {
                                                        ForEach(confettiPieces) { piece in
                                                            ConfettiShape(color: piece.color)
                                                                .frame(width: piece.size, height: piece.size)
                                                                .offset(x: piece.x, y: piece.y)
                                                                .rotationEffect(.degrees(piece.rotation))
                                                                .opacity(piece.opacity)
                                                        }
                                                    }
                                                    .onAppear {
                                                        generateConfetti(in: geometry.size)
                                                    }
                                                }
                                            }
                                            
                                            private func generateConfetti(in size: CGSize) {
                                                let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
                                                
                                                for i in 0..<50 {
                                                    let piece = ConfettiPiece(
                                                        id: UUID(),
                                                        x: CGFloat.random(in: 0...size.width),
                                                        y: -50,
                                                        size: CGFloat.random(in: 8...16),
                                                        color: colors.randomElement() ?? .blue,
                                                        rotation: Double.random(in: 0...360),
                                                        opacity: 1.0
                                                    )
                                                    confettiPieces.append(piece)
                                                    
                                                    withAnimation(.linear(duration: Double.random(in: 2...4)).delay(Double(i) * 0.02)) {
                                                        if let index = confettiPieces.firstIndex(where: { $0.id == piece.id }) {
                                                            confettiPieces[index].y = size.height + 50
                                                            confettiPieces[index].rotation += 720
                                                            confettiPieces[index].opacity = 0
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        struct ConfettiPiece: Identifiable {
                                            let id: UUID
                                            var x: CGFloat
                                            var y: CGFloat
                                            let size: CGFloat
                                            let color: Color
                                            var rotation: Double
                                            var opacity: Double
                                        }

                                        struct ConfettiShape: View {
                                            let color: Color
                                            
                                            var body: some View {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(color)
                                            }
                                        }

                                        // MARK: - Shake Effect Modifier
                                        struct ShakeEffect: GeometryEffect {
                                            var shakes: CGFloat
                                            
                                            var animatableData: CGFloat {
                                                get { shakes }
                                                set { shakes = newValue }
                                            }
                                            
                                            func effectValue(size: CGSize) -> ProjectionTransform {
                                                ProjectionTransform(
                                                    CGAffineTransform(translationX: 10 * sin(shakes * .pi * 2), y: 0)
                                                )
                                            }
                                        }
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
