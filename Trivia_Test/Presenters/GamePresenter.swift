
import SwiftUI
internal import Combine


class GamePresenter: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showingAnswer: Bool = false
    @Published var totalQuestions: Int = 0
    @Published var selectedCategory: QuizCategory = .all
    @Published var selectedDifficulty: Difficulty = .rookie
    @Published var needsToWatchAd: Bool = false
    @Published var timeExpired: Bool = false
    
    // Streak & Bonus
    @Published var streak: Streak = Streak()
    @Published var hiddenOptions: Set<Int> = []
    @Published var bonusPoints: Int = 0
    @Published var showStreakAnimation: Bool = false
    @Published var coinsEarned: Int = 0
    
    private let lifelineManager = LifelineManager.shared
    private let challengeManager = DailyChallengeManager.shared
    private let coinsManager = CoinsManager.shared
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    var pointsForCorrectAnswer: Int {
        let basePoints = 10
        let difficultyMultiplier = selectedDifficulty.pointsMultiplier
        let streakMultiplier = streak.multiplier
        return basePoints * difficultyMultiplier * streakMultiplier
    }
    
    init() {
        let filteredQuestions = QuestionsManager.shared.getFilteredQuestions(
            category: selectedCategory,
            difficulty: selectedDifficulty
        )
        self.questions = filteredQuestions.shuffled()
        self.totalQuestions = self.questions.count
        self.streak = Streak()
    }
    
    func getFilteredQuestions() -> [Question] {
        return QuestionsManager.shared.getFilteredQuestions(
            category: selectedCategory,
            difficulty: selectedDifficulty
        )
    }
    
    func resetGame() {
        let filteredQuestions = getFilteredQuestions()
        questions = filteredQuestions.shuffled()
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingAnswer = false
        totalQuestions = questions.count
        needsToWatchAd = false
        timeExpired = false
        streak = Streak()
        hiddenOptions = []
        bonusPoints = 0
        coinsEarned = 0
    }
    
    func selectAnswer(_ index: Int) {
        guard !showingAnswer else { return }
        selectedAnswer = index
        showingAnswer = true
        
        if index == currentQuestion.correctAnswer {
            processCorrectAnswer()
        } else {
            processWrongAnswer()
        }
    }
    
    private func processCorrectAnswer() {
        HapticManager.shared.success()
        let points = pointsForCorrectAnswer
        score += points
        bonusPoints = points - 10
        
        // Award coins (1 coin per 10 points)
        let coins = points / 10
        coinsEarned += coins
        
        streak.incrementStreak()
        
        if streak.currentStreak >= 3 {
            showStreakAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showStreakAnimation = false
            }
        }
        
        // Award bonus lifelines for milestones
        if streak.currentStreak == 10 {
            lifelineManager.addLifeline(type: .fiftyFifty, quantity: 1)
        } else if streak.currentStreak == 20 {
            lifelineManager.addLifeline(type: .skip, quantity: 1)
        } else if streak.currentStreak == 30 {
            lifelineManager.addLifeline(type: .extraTime, quantity: 1)
        }
        
        challengeManager.updateProgress(for: .answerCorrectly)
        if streak.currentStreak >= 5 {
            challengeManager.updateProgress(for: .perfectStreak)
        }
        
        needsToWatchAd = false
        timeExpired = false
    }

    private func processWrongAnswer() {
        HapticManager.shared.error()
        streak.resetStreak()
        needsToWatchAd = true
        timeExpired = false
        bonusPoints = 0
    }

    func handleTimeExpired() {
        HapticManager.shared.warning()
        showingAnswer = true
        needsToWatchAd = true
        timeExpired = true
        streak.resetStreak()
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showingAnswer = false
        needsToWatchAd = false
        timeExpired = false
        hiddenOptions = []
        bonusPoints = 0
        
        if currentQuestionIndex == questions.count {
            challengeManager.updateProgress(for: .completeQuizzes)
            // Award total coins earned
            coinsManager.addCoins(coinsEarned)
        }
    }
    
    func useFiftyFifty() -> Bool {
        guard lifelineManager.useLifeline(type: .fiftyFifty),
              hiddenOptions.isEmpty else {
            return false
        }
        
        let correctAnswer = currentQuestion.correctAnswer
        var wrongOptions = [0, 1, 2, 3].filter { $0 != correctAnswer }
        
        if wrongOptions.count >= 2 {
            wrongOptions.shuffle()
            hiddenOptions.insert(wrongOptions[0])
            hiddenOptions.insert(wrongOptions[1])
        }
        
        return true
    }
    
    func useSkip() -> Bool {
        guard lifelineManager.useLifeline(type: .skip) else {
            return false
        }
        
        if !isLastQuestion {
            nextQuestion()
        }
        
        return true
    }
    
    func useExtraTime() -> Bool {
        return lifelineManager.useLifeline(type: .extraTime)
    }
    
    func getLifelineQuantity(_ type: LifelineType) -> Int {
        return lifelineManager.getQuantity(for: type)
    }
    
    func finalizeGameCoins() {
        coinsManager.addCoins(coinsEarned)
    }
}
