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
    @State private var showReportSheet = false
    @State private var questionStartTime: Date = Date()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Clean Background
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // Progress Section
                    progressSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    
                    // Circular Timer
                    circularTimer
                        .frame(width: 110, height: 110)
                        .padding(.vertical, 12)
                    
                    // Category Badge
                    categoryBadge
                        .padding(.bottom, 16)
                    
                    // Question Text
                    questionText
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        .frame(height: 80)
                    
                    // Options (Fixed - No Scroll)
                    VStack(spacing: 12) {
                        ForEach(0..<presenter.currentQuestion.options.count, id: \.self) { index in
                            if !presenter.hiddenOptions.contains(index) {
                                OptionButtonModern(
                                    text: presenter.currentQuestion.options[index],
                                    letter: ["A", "B", "C", "D"][index],
                                    isSelected: presenter.selectedAnswer == index,
                                    isCorrect: presenter.showingAnswer && index == presenter.currentQuestion.correctAnswer,
                                    isWrong: presenter.showingAnswer && presenter.selectedAnswer == index && index != presenter.currentQuestion.correctAnswer,
                                    isDisabled: presenter.showingAnswer || presenter.needsToWatchAd,
                                    action: {
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
                                        stopTimer()
                                    }
                                )
                                .opacity(showQuestion ? 1 : 0)
                                .offset(y: showQuestion ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.1), value: showQuestion)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                
                // Lifeline Panel (Bottom Fixed) - Hide when showing CTAs
                VStack {
                    Spacer()
                    if !presenter.needsToWatchAd && !presenter.showingAnswer {
                        lifelinePanel
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                            .background(
                                Color(red: 0.97, green: 0.97, blue: 0.96)
                                    .ignoresSafeArea(edges: .bottom)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                // Confetti Effect
                if confettiTrigger && presenter.showingAnswer && presenter.selectedAnswer == presenter.currentQuestion.correctAnswer {
                    ConfettiView()
                        .allowsHitTesting(false)
                }
                
                // Bonus Points Animation
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
                
                // Streak Animation
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
                
                // Ad/Next Button Overlay
                if presenter.needsToWatchAd || presenter.showingAnswer {
                    VStack {
                        Spacer()
                        bottomActionArea
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
    
    // Header Section
    private var headerSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                AnalyticsManager.shared.logQuizAbandoned(
                    category: presenter.selectedCategory,
                    difficulty: presenter.selectedDifficulty,
                    questionNumber: presenter.currentQuestionIndex + 1,
                    totalQuestions: presenter.totalQuestions
                )
                HapticManager.shared.selection()
                stopTimer()
                goHome()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            // Score with coin icon
            HStack(spacing: 6) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                
                Text("\(presenter.score)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            
            Spacer()
            
            // Streak multiplier
            HStack(spacing: 6) {
                Text("x\(presenter.streak.multiplier)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Text(presenter.streak.emoji)
                    .font(.system(size: 18))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(22)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }
    
    // Progress Section
    private var progressSection: some View {
        HStack(spacing: 0) {
            Text("Question \(presenter.currentQuestionIndex + 1)/\(presenter.questions.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.gray)
            
            Spacer()
        }
    }
    
    // Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.yellow)
                    .frame(width: geometry.size.width * CGFloat(presenter.currentQuestionIndex + 1) / CGFloat(presenter.questions.count), height: 8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: presenter.currentQuestionIndex)
            }
        }
        .frame(height: 8)
    }
    
    // Circular Timer
    private var circularTimer: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(timeRemaining) / 30.0)
                .stroke(
                    timeRemaining <= 10 ? Color.red : Color.yellow,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: timeRemaining)
            
            // Timer content
            VStack(spacing: 2) {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                    .foregroundColor(timeRemaining <= 10 ? .red : Color.yellow)
                
                Text("\(timeRemaining)s")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .monospacedDigit()
            }
            .scaleEffect(timeRemaining <= 5 ? 1.1 : 1.0)
            .animation(.spring(response: 0.3).repeatCount(timeRemaining <= 5 ? 100 : 1), value: timeRemaining)
        }
        .frame(width: 110, height: 110)
    }
    
    // Category Badge
    private var categoryBadge: some View {
        Text("\(presenter.currentQuestion.category.rawValue) | \(presenter.currentQuestion.difficulty.rawValue)")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color.gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    // Question Text
    private var questionText: some View {
        Text(presenter.currentQuestion.text)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .minimumScaleFactor(0.8)
            .opacity(showQuestion ? 1 : 0)
            .scaleEffect(showQuestion ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showQuestion)
    }
    
    // Lifeline Panel
    private var lifelinePanel: some View {
        HStack(spacing: 12) {
            LifelineButtonModern(
                icon: "xmark",
                label: "50/50",
                count: presenter.getLifelineQuantity(.fiftyFifty),
                color: Color(red: 0.6, green: 0.9, blue: 0.8),
                isDisabled: presenter.showingAnswer || presenter.needsToWatchAd || presenter.getLifelineQuantity(.fiftyFifty) == 0,
                action: {
                    HapticManager.shared.selection()
                    handleLifelineUse(.fiftyFifty)
                }
            )
            
            LifelineButtonModern(
                icon: "forward.end.fill",
                label: "Skip",
                count: presenter.getLifelineQuantity(.skip),
                color: Color(red: 0.7, green: 0.8, blue: 0.95),
                isDisabled: presenter.showingAnswer || presenter.needsToWatchAd || presenter.getLifelineQuantity(.skip) == 0,
                action: {
                    HapticManager.shared.selection()
                    handleLifelineUse(.skip)
                }
            )
            
            LifelineButtonModern(
                icon: "hourglass",
                label: "+15s",
                count: presenter.getLifelineQuantity(.extraTime),
                color: Color(red: 0.95, green: 0.8, blue: 0.8),
                isDisabled: presenter.showingAnswer || presenter.needsToWatchAd || presenter.getLifelineQuantity(.extraTime) == 0,
                action: {
                    HapticManager.shared.selection()
                    handleLifelineUse(.extraTime)
                }
            )
        }
    }
    
    // Bottom Action Area
    private var bottomActionArea: some View {
        VStack(spacing: 12) {
            if presenter.needsToWatchAd {
                Button(action: {
                    guard adMobManager.isAdReady else { return }
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let rootVC = windowScene.windows.first?.rootViewController else {
                        return
                    }
                    
                    HapticManager.shared.light()
                    
                    adMobManager.onAdRewarded = {
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
                    
                    adMobManager.showAd(from: rootVC)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.rectangle.fill")
                        Text(adMobManager.isAdReady ? "Watch Ad to Continue" : "Loading Ad...")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(adMobManager.isAdReady ? Color.red : Color.gray)
                    .cornerRadius(16)
                }
                .disabled(!adMobManager.isAdReady)
            } else if presenter.showingAnswer {
                Button(action: {
                    HapticManager.shared.selection()
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
                            .fontWeight(.bold)
                        Image(systemName: presenter.isLastQuestion ? "flag.checkered" : "arrow.right")
                    }
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.orange)
                    .cornerRadius(16)
                }
            }
            
            // Report Button
            Button(action: {
                HapticManager.shared.light()
                showReportSheet = true
            }) {
                Text("Report a Bug")
                    .font(.system(size: 14))
                    .foregroundColor(Color.black)
            }
        }
    }
    
    // Lifeline Handlers
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
    
    //  Timer Functions
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

//  Modern Option Button
struct OptionButtonModern: View {
    let text: String
    let letter: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isDisabled {
                HapticManager.shared.selection()
                action()
            }
        }) {
            HStack(spacing: 12) {
                // Letter badge
                Text(letter + ".")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(
                        isCorrect ? .white :
                        isWrong ? .white :
                        isSelected ? .white :
                        Color(red: 0.5, green: 0.4, blue: 0.7)
                    )
                    .frame(width: 32, height: 32)
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(
                        isCorrect ? .white :
                        isWrong ? .white :
                        isSelected ? .white :
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    )
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                isCorrect ? Color.green :
                isWrong ? Color.red :
                isSelected ? Color.yellow :
                Color.white
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isCorrect ? Color.green :
                        isWrong ? Color.red :
                        isSelected ? Color.yellow :
                        Color.gray.opacity(0.2),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .disabled(isDisabled)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCorrect)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isWrong)
    }
}

// Modern Lifeline Button
struct LifelineButtonModern: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isDisabled ? Color.gray.opacity(0.3) : color)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isDisabled ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
                }
                
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isDisabled ? .gray : Color(red: 0.1, green: 0.1, blue: 0.2))
            }
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .disabled(isDisabled)
    }
}

// Enhanced Bonus Points Animation
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

// Confetti View
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
