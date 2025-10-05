
import SwiftUI
import GoogleMobileAds
internal import Combine

// MARK: - Models
struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let category: QuizCategory
    let difficulty: Difficulty
}

enum QuizCategory: String, CaseIterable, Codable {
    case all = "All Categories"
    case geography = "Geography"
    case science = "Science"
    case history = "History"
    case art = "Art"
    case literature = "Literature"
    case math = "Math"
    case sports = "Sports"
    case movies = "Movies"
    
    var emoji: String {
        switch self {
        case .all: return "🌟"
        case .geography: return "🌍"
        case .science: return "🔬"
        case .history: return "📜"
        case .art: return "🎨"
        case .literature: return "📚"
        case .math: return "🔢"
        case .sports: return "⚽️"
        case .movies: return "🎬"
        }
    }
}

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let totalQuestions: Int
    let category: String
    let difficulty: String
    let date: Date
    
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return (score * 100) / totalQuestions
    }
}

// MARK: - Leaderboard Manager
class LeaderboardManager {
    static let shared = LeaderboardManager()
    private let defaults = UserDefaults.standard
    private let key = "leaderboard"
    
    func getLeaderboard() -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: key),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func saveLeaderboard(_ entries: [LeaderboardEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }
}

// MARK: - AdMob Manager
class AdMobManager: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published var isAdReady = false
    @Published var isShowingAd = false
    private var rewardedAd: RewardedAd?
    var onAdDismissed: (() -> Void)?
    var onAdRewarded: (() -> Void)?
    
    // Test Ad Unit ID - Replace with your real ID in production
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    override init() {
        super.init()
        loadRewardedAd()
    }
    
    func loadRewardedAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                self?.isAdReady = false
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.isAdReady = true
            print("Rewarded ad loaded successfully")
        }
    }
    
    func showAd(from viewController: UIViewController) {
        guard let ad = rewardedAd else {
            print("Ad not ready")
            isAdReady = false
            loadRewardedAd()
            return
        }
        
        isShowingAd = true
        ad.present(from: viewController) { [weak self] in
            print("User earned reward")
            self?.onAdRewarded?()
        }
    }
    
    // MARK: - GADFullScreenContentDelegate
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed")
        isShowingAd = false
        onAdDismissed?()
        loadRewardedAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        isShowingAd = false
        isAdReady = false
        loadRewardedAd()
    }
}

// MARK: - View Controller Representable
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

// MARK: - Sample Data
let triviaQuestions = [
    // Geography - Easy
    Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, category: .geography, difficulty: .easy),
    Question(text: "Which continent is the largest?", options: ["Africa", "Asia", "Europe", "North America"], correctAnswer: 1, category: .geography, difficulty: .easy),
    Question(text: "What ocean is on the west coast of the United States?", options: ["Atlantic", "Pacific", "Indian", "Arctic"], correctAnswer: 1, category: .geography, difficulty: .easy),
    
    // Geography - Medium
    Question(text: "What is the longest river in the world?", options: ["Amazon", "Nile", "Yangtze", "Mississippi"], correctAnswer: 1, category: .geography, difficulty: .medium),
    Question(text: "Which country has the most natural lakes?", options: ["USA", "Canada", "Russia", "Brazil"], correctAnswer: 1, category: .geography, difficulty: .medium),
    
    // Geography - Hard
    Question(text: "What is the smallest country in the world?", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"], correctAnswer: 1, category: .geography, difficulty: .hard),
    
    // Science - Easy
    Question(text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, category: .science, difficulty: .easy),
    Question(text: "Which element has the chemical symbol 'O'?", options: ["Gold", "Oxygen", "Silver", "Iron"], correctAnswer: 1, category: .science, difficulty: .easy),
    Question(text: "How many bones are in the human body?", options: ["186", "206", "226", "246"], correctAnswer: 1, category: .science, difficulty: .easy),
    
    // Science - Medium
    Question(text: "What is the speed of light?", options: ["300,000 km/s", "150,000 km/s", "450,000 km/s", "600,000 km/s"], correctAnswer: 0, category: .science, difficulty: .medium),
    Question(text: "What is the chemical symbol for gold?", options: ["Go", "Gd", "Au", "Ag"], correctAnswer: 2, category: .science, difficulty: .medium),
    
    // Science - Hard
    Question(text: "What is the half-life of Carbon-14?", options: ["5,730 years", "10,000 years", "2,500 years", "15,000 years"], correctAnswer: 0, category: .science, difficulty: .hard),
    
    // History - Easy
    Question(text: "In what year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctAnswer: 2, category: .history, difficulty: .easy),
    Question(text: "Who was the first President of the United States?", options: ["Thomas Jefferson", "George Washington", "John Adams", "Benjamin Franklin"], correctAnswer: 1, category: .history, difficulty: .easy),
    
    // History - Medium
    Question(text: "What year did the Berlin Wall fall?", options: ["1987", "1988", "1989", "1990"], correctAnswer: 2, category: .history, difficulty: .medium),
    Question(text: "Who was the first person to walk on the moon?", options: ["Buzz Aldrin", "Neil Armstrong", "John Glenn", "Yuri Gagarin"], correctAnswer: 1, category: .history, difficulty: .medium),
    
    // History - Hard
    Question(text: "What year was the Magna Carta signed?", options: ["1215", "1315", "1415", "1515"], correctAnswer: 0, category: .history, difficulty: .hard),
    
    // Art - Easy
    Question(text: "Who painted the Mona Lisa?", options: ["Van Gogh", "Da Vinci", "Picasso", "Monet"], correctAnswer: 1, category: .art, difficulty: .easy),
    Question(text: "What color do you get when you mix red and blue?", options: ["Green", "Purple", "Orange", "Brown"], correctAnswer: 1, category: .art, difficulty: .easy),
    
    // Art - Medium
    Question(text: "Who painted 'The Starry Night'?", options: ["Monet", "Van Gogh", "Rembrandt", "Picasso"], correctAnswer: 1, category: .art, difficulty: .medium),
    
    // Art - Hard
    Question(text: "What art movement was Pablo Picasso associated with?", options: ["Impressionism", "Cubism", "Surrealism", "Expressionism"], correctAnswer: 1, category: .art, difficulty: .hard),
    
    // Literature - Easy
    Question(text: "Who wrote 'Romeo and Juliet'?", options: ["Dickens", "Hemingway", "Shakespeare", "Austen"], correctAnswer: 2, category: .literature, difficulty: .easy),
    Question(text: "What is the first book in the Harry Potter series?", options: ["Chamber of Secrets", "Philosopher's Stone", "Prisoner of Azkaban", "Goblet of Fire"], correctAnswer: 1, category: .literature, difficulty: .easy),
    
    // Literature - Medium
    Question(text: "Who wrote '1984'?", options: ["Aldous Huxley", "George Orwell", "Ray Bradbury", "H.G. Wells"], correctAnswer: 1, category: .literature, difficulty: .medium),
    
    // Literature - Hard
    Question(text: "What year was 'Moby Dick' published?", options: ["1841", "1851", "1861", "1871"], correctAnswer: 1, category: .literature, difficulty: .hard),
    
    // Math - Easy
    Question(text: "What is the smallest prime number?", options: ["0", "1", "2", "3"], correctAnswer: 2, category: .math, difficulty: .easy),
    Question(text: "What is 12 × 12?", options: ["124", "144", "154", "164"], correctAnswer: 1, category: .math, difficulty: .easy),
    
    // Math - Medium
    Question(text: "What is the value of π (pi) to 2 decimal places?", options: ["3.12", "3.14", "3.16", "3.18"], correctAnswer: 1, category: .math, difficulty: .medium),
    
    // Math - Hard
    Question(text: "What is the square root of 169?", options: ["11", "12", "13", "14"], correctAnswer: 2, category: .math, difficulty: .hard),
    
    // Sports - Easy
    Question(text: "How many players are on a soccer team?", options: ["9", "10", "11", "12"], correctAnswer: 2, category: .sports, difficulty: .easy),
    Question(text: "What sport is played at Wimbledon?", options: ["Golf", "Tennis", "Cricket", "Badminton"], correctAnswer: 1, category: .sports, difficulty: .easy),
    
    // Sports - Medium
    Question(text: "Which country won the FIFA World Cup in 2018?", options: ["Germany", "Brazil", "France", "Argentina"], correctAnswer: 2, category: .sports, difficulty: .medium),
    
    // Sports - Hard
    Question(text: "What year were the first modern Olympic Games held?", options: ["1886", "1896", "1906", "1916"], correctAnswer: 1, category: .sports, difficulty: .hard),
    
    // Movies - Easy
    Question(text: "What is the highest-grossing film of all time (unadjusted)?", options: ["Titanic", "Avatar", "Avengers: Endgame", "Star Wars"], correctAnswer: 1, category: .movies, difficulty: .easy),
    Question(text: "Who played Iron Man in the Marvel movies?", options: ["Chris Evans", "Robert Downey Jr.", "Chris Hemsworth", "Mark Ruffalo"], correctAnswer: 1, category: .movies, difficulty: .easy),
    
    // Movies - Medium
    Question(text: "What year was the first Toy Story movie released?", options: ["1993", "1995", "1997", "1999"], correctAnswer: 1, category: .movies, difficulty: .medium),
    
    // Movies - Hard
    Question(text: "Who directed 'The Shawshank Redemption'?", options: ["Steven Spielberg", "Christopher Nolan", "Frank Darabont", "Martin Scorsese"], correctAnswer: 2, category: .movies, difficulty: .hard),
]

// MARK: - Content View
struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var adMobManager = AdMobManager()
    @State private var currentScreen: Screen = .home
    
    enum Screen {
        case home
        case settings
        case game
        case results
        case leaderboard
    }
    
    var body: some View {
        switch currentScreen {
        case .home:
            HomeView(
                startGame: { currentScreen = .settings },
                showLeaderboard: { currentScreen = .leaderboard }
            )
        case .settings:
            SettingsView(
                startGame: {
                    gameViewModel.resetGame()
                    currentScreen = .game
                },
                goHome: { currentScreen = .home },
                viewModel: gameViewModel
            )
        case .game:
            GameView(
                viewModel: gameViewModel,
                adMobManager: adMobManager,
                showResults: { currentScreen = .results },
                goHome: { currentScreen = .home }
            )
        case .results:
            ResultsView(
                viewModel: gameViewModel,
                playAgain: { currentScreen = .settings },
                goHome: { currentScreen = .home },
                showLeaderboard: { currentScreen = .leaderboard }
            )
        case .leaderboard:
            LeaderboardView(goHome: { currentScreen = .home })
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    let startGame: () -> Void
    let showLeaderboard: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("🧠")
                    .font(.system(size: 80))
                
                Text("Trivia Master")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Test Your Knowledge!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: startGame) {
                        Text("Start Quiz")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(width: 250, height: 60)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                    
                    Button(action: showLeaderboard) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Leaderboard")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(30)
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    let startGame: () -> Void
    let goHome: () -> Void
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                HStack {
                    Button(action: goHome) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                
                Text("Quiz Settings")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Category Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Select Category")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(QuizCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: viewModel.selectedCategory == category,
                                        action: { viewModel.selectedCategory = category }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        
                        // Difficulty Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Select Difficulty")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                    DifficultyButton(
                                        difficulty: difficulty,
                                        isSelected: viewModel.selectedDifficulty == difficulty,
                                        action: { viewModel.selectedDifficulty = difficulty }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        
                        // Available Questions Count
                        Text("Available Questions: \(viewModel.getFilteredQuestions().count)")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: startGame) {
                            Text("Start Game")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 60)
                                .background(viewModel.getFilteredQuestions().isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(30)
                        }
                        .disabled(viewModel.getFilteredQuestions().isEmpty)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: QuizCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.emoji)
                    .font(.system(size: 36))
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
        }
        .foregroundColor(.black)
    }
}

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(difficulty.rawValue)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 12, height: 12)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Game View
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var adMobManager: AdMobManager
    let showResults: () -> Void
    let goHome: () -> Void
    @Environment(\.viewController) var viewControllerHolder: ViewControllerHolder
    @State private var showAdPrompt = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: goHome) {
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Score: \(viewModel.score)")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .padding()
                
                // Progress
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(viewModel.currentQuestion.category.emoji)
                        Text(viewModel.currentQuestion.category.rawValue)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                    
                    Circle()
                        .fill(viewModel.currentQuestion.difficulty.color)
                        .frame(width: 12, height: 12)
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.questions.count))
                    .padding(.horizontal)
                
                Spacer()
                
                // Question Card
                VStack(spacing: 25) {
                    Text(viewModel.currentQuestion.text)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    ForEach(0..<viewModel.currentQuestion.options.count, id: \.self) { index in
                        OptionButton(
                            text: viewModel.currentQuestion.options[index],
                            isSelected: viewModel.selectedAnswer == index,
                            isCorrect: viewModel.showingAnswer && index == viewModel.currentQuestion.correctAnswer,
                            isWrong: viewModel.showingAnswer && viewModel.selectedAnswer == index && index != viewModel.currentQuestion.correctAnswer,
                            action: { viewModel.selectAnswer(index) }
                        )
                        .disabled(viewModel.showingAnswer || viewModel.needsToWatchAd)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                
                Spacer()
                
                // Ad Prompt or Next Button
                if viewModel.needsToWatchAd {
                    VStack(spacing: 15) {
                        Text("❌ Wrong Answer!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("Watch an ad to continue")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            if let vc = viewControllerHolder.value {
                                adMobManager.onAdRewarded = {
                                    viewModel.needsToWatchAd = false
                                    viewModel.showingAnswer = false
                                    viewModel.selectedAnswer = nil
                                }
                                adMobManager.showAd(from: vc)
                            }
                        }) {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text(adMobManager.isAdReady ? "Watch Ad" : "Loading Ad...")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(adMobManager.isAdReady ? Color.red : Color.gray)
                            .cornerRadius(25)
                        }
                        .disabled(!adMobManager.isAdReady)
                    }
                    .padding(.bottom, 30)
                } else if viewModel.showingAnswer && !viewModel.needsToWatchAd {
                    Button(action: {
                        if viewModel.isLastQuestion {
                            showResults()
                        } else {
                            viewModel.nextQuestion()
                        }
                    }) {
                        Text(viewModel.isLastQuestion ? "See Results" : "Next Question")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.3)
        } else if isWrong {
            return Color.red.opacity(0.3)
        } else if isSelected {
            return Color.blue.opacity(0.2)
        } else {
            return Color.gray.opacity(0.1)
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
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
    }
}

// MARK: - Results View
struct ResultsView: View {
    @ObservedObject var viewModel: GameViewModel
    let playAgain: () -> Void
    let goHome: () -> Void
    let showLeaderboard: () -> Void
    @State private var showNameInput = false
    @State private var playerName = ""
    @State private var savedToLeaderboard = false
    
    var percentage: Int {
        guard viewModel.totalQuestions > 0 else { return 0 }
        return (viewModel.score * 100) / viewModel.totalQuestions
    }
    
    var message: String {
        switch percentage {
        case 90...100: return "Outstanding! 🏆"
        case 70..<90: return "Great Job! 🎉"
        case 50..<70: return "Good Effort! 👍"
        default: return "Keep Practicing! 💪"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text(message)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Text("\(viewModel.score)/\(viewModel.totalQuestions)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(percentage)% Correct")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text(viewModel.selectedCategory.emoji)
                                .font(.title)
                            Text(viewModel.selectedCategory.rawValue)
                                .font(.caption)
                        }
                        
                        VStack {
                            Circle()
                                .fill(viewModel.selectedDifficulty.color)
                                .frame(width: 20, height: 20)
                            Text(viewModel.selectedDifficulty.rawValue)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
                if !savedToLeaderboard {
                    Button(action: { showNameInput = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Save to Leaderboard")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.yellow.opacity(0.8))
                        .cornerRadius(25)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button(action: playAgain) {
                        Text("Play Again")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .frame(width: 250, height: 60)
                            .background(Color.white)
                            .cornerRadius(30)
                    }
                    
                    Button(action: showLeaderboard) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Leaderboard")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(30)
                    }
                    
                    Button(action: goHome) {
                        Text("Home")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 60)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showNameInput) {
            NameInputView(
                playerName: $playerName,
                onSave: {
                    saveToLeaderboard()
                    showNameInput = false
                    savedToLeaderboard = true
                }
            )
        }
    }
    
    func saveToLeaderboard() {
        let entry = LeaderboardEntry(
            id: UUID(),
            playerName: playerName.isEmpty ? "Anonymous" : playerName,
            score: viewModel.score,
            totalQuestions: viewModel.totalQuestions,
            category: viewModel.selectedCategory.rawValue,
            difficulty: viewModel.selectedDifficulty.rawValue,
            date: Date()
        )
        
        var leaderboard = LeaderboardManager.shared.getLeaderboard()
        leaderboard.append(entry)
        leaderboard.sort { $0.percentage > $1.percentage }
        
        if leaderboard.count > 50 {
            leaderboard = Array(leaderboard.prefix(50))
        }
        
        LeaderboardManager.shared.saveLeaderboard(leaderboard)
    }
}

// MARK: - Name Input View
struct NameInputView: View {
    @Binding var playerName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Your Name")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                TextField("Player Name", text: $playerName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: onSave) {
                    Text("Save Score")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    let goHome: () -> Void
    @State private var leaderboard: [LeaderboardEntry] = []
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: goHome) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    
                    Button(action: {
                        LeaderboardManager.shared.saveLeaderboard([])
                        leaderboard = []
                    }) {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                Text("🏆 Leaderboard")
                    .font(.system(size: 36, weight: .bold))
                
                if leaderboard.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "trophy.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No scores yet!")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Play a game to get on the leaderboard")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            leaderboard = LeaderboardManager.shared.getLeaderboard()
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Text(rankEmoji)
                .font(.title)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                
                HStack(spacing: 10) {
                    Text(entry.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text(entry.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(entry.difficulty).opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.percentage)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("\(entry.score)/\(entry.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        default: return .gray
        }
    }
}

// MARK: - View Model
class GameViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showingAnswer: Bool = false
    @Published var totalQuestions: Int = 0
    @Published var selectedCategory: QuizCategory = .all
    @Published var selectedDifficulty: Difficulty = .easy
    @Published var needsToWatchAd: Bool = false
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    init() {
        let filteredQuestions = triviaQuestions.filter { $0.difficulty == .easy }
        let shuffledQuestions = filteredQuestions.shuffled()
        self.questions = shuffledQuestions
        self.currentQuestionIndex = 0
        self.score = 0
        self.selectedAnswer = nil
        self.showingAnswer = false
        self.totalQuestions = shuffledQuestions.count
        self.selectedCategory = .all
        self.selectedDifficulty = .easy
        self.needsToWatchAd = false
    }
    
    func getFilteredQuestions() -> [Question] {
        var filtered = triviaQuestions
        
        if selectedCategory != .all {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        filtered = filtered.filter { $0.difficulty == selectedDifficulty }
        
        return filtered
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
    }
    
    func selectAnswer(_ index: Int) {
        guard !showingAnswer else { return }
        selectedAnswer = index
        showingAnswer = true
        
        if index == currentQuestion.correctAnswer {
            score += 1
            needsToWatchAd = false
        } else {
            // Wrong answer - user needs to watch ad
            needsToWatchAd = true
        }
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showingAnswer = false
        needsToWatchAd = false
    }
}
