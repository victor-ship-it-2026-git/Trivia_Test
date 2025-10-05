import SwiftUI
internal import Combine

// MARK: - Models
struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let category: String
}

// MARK: - Sample Data
let triviaQuestions = [
    Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, category: "Geography"),
    Question(text: "Who painted the Mona Lisa?", options: ["Van Gogh", "Da Vinci", "Picasso", "Monet"], correctAnswer: 1, category: "Art"),
    Question(text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, category: "Science"),
    Question(text: "In what year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctAnswer: 2, category: "History"),
    Question(text: "What is the smallest prime number?", options: ["0", "1", "2", "3"], correctAnswer: 2, category: "Math"),
    Question(text: "Which element has the chemical symbol 'O'?", options: ["Gold", "Oxygen", "Silver", "Iron"], correctAnswer: 1, category: "Science"),
    Question(text: "Who wrote 'Romeo and Juliet'?", options: ["Dickens", "Hemingway", "Shakespeare", "Austen"], correctAnswer: 2, category: "Literature"),
    Question(text: "What is the longest river in the world?", options: ["Amazon", "Nile", "Yangtze", "Mississippi"], correctAnswer: 1, category: "Geography")
]

// MARK: - Content View
struct ContentView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var currentScreen: Screen = .home
    
    enum Screen {
        case home
        case game
        case results
    }
    
    var body: some View {
        switch currentScreen {
        case .home:
            HomeView(startGame: {
                gameViewModel.resetGame()
                currentScreen = .game
            })
        case .game:
            GameView(
                viewModel: gameViewModel,
                showResults: { currentScreen = .results },
                goHome: { currentScreen = .home }
            )
        case .results:
            ResultsView(
                viewModel: gameViewModel,
                playAgain: {
                    gameViewModel.resetGame()
                    currentScreen = .game
                },
                goHome: { currentScreen = .home }
            )
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    let startGame: () -> Void
    
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
                
                Button(action: startGame) {
                    Text("Start Quiz")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(width: 250, height: 60)
                        .background(Color.white)
                        .cornerRadius(30)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Game View
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    let showResults: () -> Void
    let goHome: () -> Void
    
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
                    
                    Text(viewModel.currentQuestion.category)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
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
                        .disabled(viewModel.showingAnswer)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                
                Spacer()
                
                // Next Button
                if viewModel.showingAnswer {
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
                }
                .padding(40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                
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
                    
                    Button(action: goHome) {
                        Text("Home")
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

// MARK: - View Model
class GameViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var score: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showingAnswer: Bool = false
    @Published var totalQuestions: Int = 0
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }
    
    init() {
        self.resetGame()
    }
    
    func resetGame() {
        questions = triviaQuestions.shuffled()
        currentQuestionIndex = 0
        score = 0
        selectedAnswer = nil
        showingAnswer = false
        totalQuestions = questions.count
    }
    
    func selectAnswer(_ index: Int) {
        guard !showingAnswer else { return }
        selectedAnswer = index
        showingAnswer = true
        
        if index == currentQuestion.correctAnswer {
            score += 1
        }
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        selectedAnswer = nil
        showingAnswer = false
    }
}
