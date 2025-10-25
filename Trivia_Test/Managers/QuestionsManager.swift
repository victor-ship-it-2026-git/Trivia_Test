import Foundation

// Helper struct to decode JSON (matches your JSON structure exactly)
struct QuestionJSON: Codable {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let category: String  // String from JSON
    let difficulty: String  // String from JSON
}

class QuestionsManager {
    static let shared = QuestionsManager()
    private var allQuestions: [Question] = []
    
    private init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                
                // Decode as QuestionJSON first
                let questionsJSON = try decoder.decode([QuestionJSON].self, from: data)
                
                // Convert to Question objects
                for questionJSON in questionsJSON {
                    if let question = convertToQuestion(questionJSON) {
                        allQuestions.append(question)
                    } else {
                        print("⚠️ Skipped question: '\(questionJSON.text)' - Category: \(questionJSON.category), Difficulty: \(questionJSON.difficulty)")
                    }
                }
                
                print("✅ Successfully loaded \(allQuestions.count) questions from JSON")
                printBreakdown()
                
            } catch {
                print("❌ Error loading questions from JSON: \(error)")
                print("❌ Error details: \(error.localizedDescription)")
                loadFallbackQuestions()
            }
        } else {
            print("⚠️ questions.json not found, using fallback questions")
            loadFallbackQuestions()
        }
    }
    
    private func convertToQuestion(_ json: QuestionJSON) -> Question? {
        // Convert string category to enum
        guard let category = mapCategory(json.category) else {
            print("⚠️ Unknown category: '\(json.category)'")
            return nil
        }
        
        // Convert string difficulty to enum
        guard let difficulty = mapDifficulty(json.difficulty) else {
            print("⚠️ Unknown difficulty: '\(json.difficulty)'")
            return nil
        }
        
        return Question(
            text: json.text,
            options: json.options,
            correctAnswer: json.correctAnswer,
            category: category,
            difficulty: difficulty
        )
    }
    
    private func mapCategory(_ categoryString: String) -> QuizCategory? {
        switch categoryString.lowercased() {
        case "geography": return .geography
        case "science": return .science
        case "history": return .history
        case "movies": return .movies
        case "math", "mathematics": return .math
        case "music": return .music
        case "sports": return .sports
        case "pop culture", "popculture": return .popCulture
        case "celebrities", "celebrity": return .celebrities
        case "the 90s", "90s", "nineties": return .the90s
        case "2000s era", "2000s", "two thousands": return .the2000s
        case "gen z", "genz", "generation z": return .genZ
        case "all", "all categories": return .all
        default: return nil
        }
    }
    
    private func mapDifficulty(_ difficultyString: String) -> Difficulty? {
        switch difficultyString.lowercased() {
        case "rookie", "easy": return .rookie
        case "amateur", "medium": return .amateur
        case "pro", "hard": return .pro
        case "master": return .master
        case "legend": return .legend
        case "genius", "expert": return .genius
        default: return nil
        }
    }
    
    private func printBreakdown() {
        print("\n=== QUESTIONS BREAKDOWN ===")
        
        // By category
        print("\n📂 By Category:")
        for category in QuizCategory.allCases {
            let count = allQuestions.filter { $0.category == category }.count
            if count > 0 {
                print("   \(category.emoji) \(category.rawValue): \(count)")
            }
        }
        
        // By difficulty
        print("\n⚡️ By Difficulty:")
        for difficulty in Difficulty.allCases {
            let count = allQuestions.filter { $0.difficulty == difficulty }.count
            if count > 0 {
                print("   \(difficulty.emoji) \(difficulty.rawValue): \(count)")
            }
        }
        print("========================\n")
    }
    
    func getQuestions() -> [Question] {
        return allQuestions
    }
    
    func getFilteredQuestions(category: QuizCategory, difficulty: Difficulty) -> [Question] {
        var filtered = allQuestions
        
        // Filter by category (if not "All")
        if category != .all {
            filtered = filtered.filter { $0.category == category }
            print("🔍 Filtered by category \(category.rawValue): \(filtered.count) questions")
        }
        
        // Filter by difficulty
        filtered = filtered.filter { $0.difficulty == difficulty }
        print("🔍 Filtered by difficulty \(difficulty.rawValue): \(filtered.count) questions")
        
        if filtered.isEmpty {
            print("⚠️ WARNING: No questions found for \(category.rawValue) - \(difficulty.rawValue)")
            print("   Total questions in manager: \(allQuestions.count)")
            print("   Questions for this category: \(allQuestions.filter { $0.category == category }.count)")
            print("   Questions for this difficulty: \(allQuestions.filter { $0.difficulty == difficulty }.count)")
        }
        
        return filtered
    }
    
    private func loadFallbackQuestions() {
        allQuestions = [
            // Rookie Questions
            Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, category: .geography, difficulty: .rookie),
            Question(text: "What color is the sky on a clear day?", options: ["Green", "Blue", "Red", "Yellow"], correctAnswer: 1, category: .science, difficulty: .rookie),
            Question(text: "How many days are in a week?", options: ["5", "6", "7", "8"], correctAnswer: 2, category: .math, difficulty: .rookie),
            
            // Amateur Questions
            Question(text: "Which continent is the largest by area?", options: ["Africa", "Asia", "Europe", "North America"], correctAnswer: 1, category: .geography, difficulty: .amateur),
            Question(text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, category: .science, difficulty: .amateur),
            
            // Pro Questions
            Question(text: "What is the longest river in the world?", options: ["Amazon", "Nile", "Yangtze", "Mississippi"], correctAnswer: 1, category: .geography, difficulty: .pro),
            Question(text: "Which element has the chemical symbol 'Au'?", options: ["Silver", "Gold", "Aluminum", "Argon"], correctAnswer: 1, category: .science, difficulty: .pro),
            
            // Master Questions
            Question(text: "What is the smallest country in the world?", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"], correctAnswer: 1, category: .geography, difficulty: .master),
            
            // Legend Questions
            Question(text: "What is the capital of Kyrgyzstan?", options: ["Bishkek", "Tashkent", "Dushanbe", "Astana"], correctAnswer: 0, category: .geography, difficulty: .legend),
            
            // Genius Questions
            Question(text: "What is the Heisenberg Uncertainty Principle about?", options: ["Energy and time", "Position and momentum", "Mass and velocity", "Temperature and pressure"], correctAnswer: 1, category: .science, difficulty: .genius),
        ]
        print("ℹ️ Loaded \(allQuestions.count) fallback questions")
    }
}
