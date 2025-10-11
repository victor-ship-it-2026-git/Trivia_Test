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
    @State private var pulseEffect = false
    @State private var rotationEffect: Double = 0
    @State private var confettiTrigger = false
    @State private var showReportSheet = false  // NEW: Report sheet state
    @State private var questionStartTime: Date = Date()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated Background
                AnimatedBackgroundView(colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with Streak - Fixed Height
                    headerSection
                        .frame(height: 80)
                        .zIndex(3)
                    
                    // Lifeline Panel - Fixed Height
                    LifelinePanel(presenter: presenter, onUseLifeline: handleLifelineUse)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .frame(height: 80)
                        .zIndex(2)
                    
                    // Progress Info - Fixed Height
                    progressSection
                        .frame(height: 35)
                        .padding(.horizontal)
                    
                    // Timer Progress Bar - Fixed Height
                    timerProgressBar
                        .frame(height: 16)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    // Question Card - Takes remaining space
                    questionCard
                        .frame(height: geometry.size.height * 0.45)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    
                    Spacer(minLength: 0)
                    
                    // Bottom Action Area - Fixed Height
                    bottomActionArea
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                }
                
                // Confetti Effect for correct answers
                if confettiTrigger && presenter.showingAnswer && presenter.selectedAnswer == presenter.currentQuestion.correctAnswer {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                
                // Bonus Points Animation with enhanced effect
                if presenter.bonusPoints > 10 {
                    VStack {
                        Spacer()
                            .frame(height: geometry.size.height * 0.3)
                        
                        EnhancedBonusPointsAnimation(
                            points: presenter.bonusPoints,
                            multiplier: presenter.streak.multiplier
                        )
                        
                        Spacer()
                    }
                }
                
                // Enhanced Streak Animation
                if presenter.showStreakAnimation {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Text(presenter.streak.emoji)
                                .font(.system(size: 100))
                                .scaleEffect(pulseEffect ? 1.5 : 1.3)
                                .rotationEffect(.degrees(rotationEffect))
                                .shadow(color: .orange, radius: 20)
                            
                            Text("STREAK!")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .orange, radius: 10)
                                .scaleEffect(pulseEffect ? 1.1 : 1.0)
                            
                            Text("×\(presenter.streak.multiplier) Multiplier!")
                                .font(.title2)
                                .foregroundColor(.orange)
                                .shadow(color: .orange, radius: 10)
                        }
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                pulseEffect = true
                            }
                            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                                rotationEffect = 360
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Game")

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                
                showQuestion = true
            }
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .sheet(isPresented: $showReportSheet) {
            ReportQuestionView(question: presenter.currentQuestion)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                AnalyticsManager.shared.logQuizAbandoned(
                    category: presenter.selectedCategory,
                    difficulty: presenter.selectedDifficulty,
                    questionNumber: presenter.currentQuestionIndex + 1,
                    totalQuestions: presenter.totalQuestions
                )
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    stopTimer()
                    goHome()
                }
            }) {
                Image(systemName: "house.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.dynamicCardBackground)
                            .shadow(color: Color.blue.opacity(0.3), radius: 5)
                    )
            }
            .scaleEffect(showQuestion ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: showQuestion)
            
            StreakDisplay(streak: presenter.streak, showAnimation: presenter.showStreakAnimation)
                .scaleEffect(showQuestion ? 1.0 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: showQuestion)
            
            Spacer()
            
            // Report Button - NEW
            Button(action: {
                HapticManager.shared.light()
                showReportSheet = true
            }) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(.orange)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.dynamicCardBackground)
                            .shadow(color: Color.orange.opacity(0.3), radius: 5)
                    )
            }
            .scaleEffect(showQuestion ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3), value: showQuestion)
            
            // Animated Timer
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.title3)
                    .rotationEffect(.degrees(timeRemaining <= 5 ? -10 : 0))
                    .animation(.spring(response: 0.3).repeatCount(timeRemaining <= 5 ? 100 : 1), value: timeRemaining)
                
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
                    .shadow(color: timeRemaining <= 10 ? Color.red.opacity(0.5) : Color.blue.opacity(0.3), radius: 8)
            )
            .overlay(
                Capsule()
                    .stroke(timeRemaining <= 10 ? Color.red : Color.blue, lineWidth: 2)
            )
            .scaleEffect(timeRemaining <= 5 ? 1.15 : 1.0)
            .animation(.spring(response: 0.3).repeatCount(timeRemaining <= 5 ? 100 : 1), value: timeRemaining)
            .scaleEffect(showQuestion ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.4), value: showQuestion)
            
            Spacer()
            
            // Animated Score
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
            .scaleEffect(showQuestion ? 1.0 : 0.5)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5), value: showQuestion)
        }
        .padding(.horizontal)
    }
    
    private var progressSection: some View {
        HStack {
            Text("Q \(presenter.currentQuestionIndex + 1)/\(presenter.questions.count)")
                .font(.subheadline)
                .foregroundColor(.dynamicSecondaryText)
                .opacity(showQuestion ? 1 : 0)
                .animation(.easeIn(duration: 0.3).delay(0.5), value: showQuestion)
            
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
            .scaleEffect(showQuestion ? 1.0 : 0.8)
            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.6), value: showQuestion)
            
            Circle()
                .fill(presenter.currentQuestion.difficulty.color)
                .frame(width: 10, height: 10)
                .scaleEffect(showQuestion ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.7), value: showQuestion)
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
                    .shadow(color: timeRemaining <= 10 ? Color.red.opacity(0.6) : Color.blue.opacity(0.3), radius: 4)
            }
        }
        .frame(height: 6)
    }
    
    private var questionCard: some View {
        VStack(spacing: 0) {
            // Question text area - fixed height
            VStack {
                Text(presenter.currentQuestion.text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.dynamicText)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
                    .opacity(showQuestion ? 1 : 0)
                    .scaleEffect(showQuestion ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showQuestion)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(.top)
            
            // Options area - fixed spacing
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
                                    let timeSpent = Date().timeIntervalSince(questionStartTime)
                                    AnalyticsManager.shared.logQuestionAnswered(
                                        isCorrect: index == presenter.currentQuestion.correctAnswer,
                                        questionNumber: presenter.currentQuestionIndex + 1,
                                        category: presenter.selectedCategory,
                                        difficulty: presenter.selectedDifficulty,
                                        timeSpent: timeSpent
                                    )

                                    presenter.selectAnswer(index)
                                    if index == presenter.currentQuestion.correctAnswer {
                                        confettiTrigger = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            confettiTrigger = false
                                        }
                                    }
                                }
                                stopTimer()
                            }
                        )
                        .opacity(showQuestion ? 1 : 0)
                        .offset(x: showQuestion ? 0 : -50)
                        .rotationEffect(.degrees(showQuestion ? 0 : -10))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.1), value: showQuestion)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15), radius: 10, x: 0, y: 5)
                .opacity(showQuestion ? 1 : 0)
                .scaleEffect(showQuestion ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showQuestion)
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
                        .scaleEffect(pulseEffect ? 1.1 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                pulseEffect = true
                            }
                        }
                        
                        Button(action: {
                            print("🎯 Watch Ad button tapped")
                            print("📱 Ad ready state: \(adMobManager.isAdReady)")
                            
                            guard adMobManager.isAdReady else {
                                print("⚠️ Ad not ready yet")
                                return
                            }
                            
                            // Get the view controller
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                  let rootVC = windowScene.windows.first?.rootViewController else {
                                print("❌ Could not get root view controller")
                                return
                            }
                            
                            print("✅ Showing ad...")
                            HapticManager.shared.light()
                            
                            adMobManager.onAdRewarded = {
                                print("✅ Ad reward granted")
                                Task { @MainActor in
                                    withAnimation {
                                        presenter.needsToWatchAd = false
                                        presenter.showingAnswer = false
                                        presenter.selectedAnswer = nil
                                        presenter.timeExpired = false
                                    }
                                    resetTimer()
                                }
                            }
                            
                            adMobManager.onAdDismissed = {
                                print("📱 Ad dismissed")
                            }
                            
                            adMobManager.showAd(from: rootVC)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "play.rectangle.fill")
                                Text(adMobManager.isAdReady ? "Watch Ad to Continue" : "Loading Ad...")
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
                            .shadow(color: adMobManager.isAdReady ? Color.red.opacity(0.5) : Color.clear, radius: 10, x: 0, y: 5)
                        }
                        .allowsHitTesting(true)
                        .disabled(!adMobManager.isAdReady)
                        .opacity(adMobManager.isAdReady ? 1.0 : 0.6)
                        .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if presenter.showingAnswer {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showQuestion = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if presenter.isLastQuestion {
                                stopTimer()
                                presenter.finalizeGameCoins()
                                showResults()
                            } else {
                                presenter.nextQuestion()
                                resetTimer()
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    showQuestion = true
                                }
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
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Lifeline Handlers
    private func handleLifelineUse(_ type: LifelineType) {
        AnalyticsManager.shared.logLifelineUsed(
                lifelineType: type,
                questionNumber: presenter.currentQuestionIndex + 1,
                category: presenter.selectedCategory,
                difficulty: presenter.selectedDifficulty
            )
            
        switch type {
        case .fiftyFifty:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                _ = presenter.useFiftyFifty()
            }
            
        case .skip:
            if presenter.useSkip() {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    showQuestion = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    resetTimer()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        showQuestion = true
                    }
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
    
    // MARK: - Timer Functions
    private func startTimer() {
        stopTimer()
        timeRemaining = 30
        questionStartTime = Date()
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

// MARK: - Animated Background
struct AnimatedBackgroundView: View {
    let colorScheme: ColorScheme
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colorScheme == .dark ?
                [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Enhanced Bonus Points Animation
struct EnhancedBonusPointsAnimation: View {
    let points: Int
    let multiplier: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        VStack(spacing: 2) {
            Text("+\(points)")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.green)
                .shadow(color: .green, radius: 10)
            
            if multiplier > 1 {
                Text("×\(multiplier) Streak!")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .shadow(color: .orange, radius: 10)
            }
        }
        .scaleEffect(scale)
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.2
            }
            withAnimation(.easeOut(duration: 1.5)) {
                offset = -80
                opacity = 0
                scale = 1.5
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateConfetti(in: geometry.size)
            }
        }
    }
    
    private func generateConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .pink, .purple]
        
        for _ in 0..<50 {
            let particle = ConfettiParticle(
                id: UUID(),
                x: CGFloat.random(in: 0...size.width),
                y: -20,
                size: CGFloat.random(in: 8...15),
                color: colors.randomElement() ?? .blue,
                opacity: 1.0
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: Double.random(in: 2.0...3.5))) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].y = size.height + 50
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}
