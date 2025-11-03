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
    
    // Map each category to its JSON filename
    private let categoryFileNames: [QuizCategory: String] = [
        .geography: "questions_geography",
        .science: "questions_science",
        .history: "questions_history",
        .movies: "questions_movies",
        .math: "questions_math",
        .music: "questions_music",
        .sports: "questions_sports",
        .popCulture: "questions_popculture",
        .celebrities: "questions_celebrities",
        .the90s: "questions_90s",
        .the2000s: "questions_2000s",
        .genZ: "questions_genz"
    ]
    
    private init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        allQuestions.removeAll()
        
        // Load questions from each category file
        for (category, fileName) in categoryFileNames {
            loadQuestionsFromFile(fileName: fileName, expectedCategory: category)
        }
        
        print("✅ Successfully loaded \(allQuestions.count) total questions from all category files")
        printBreakdown()
    }
    
    private func loadQuestionsFromFile(fileName: String, expectedCategory: QuizCategory) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ Warning: \(fileName).json not found - skipping this category")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            
            // Decode as QuestionJSON first
            let questionsJSON = try decoder.decode([QuestionJSON].self, from: data)
            
            var loadedCount = 0
            var skippedCount = 0
            
            // Convert to Question objects
            for questionJSON in questionsJSON {
                if let question = convertToQuestion(questionJSON, expectedCategory: expectedCategory) {
                    allQuestions.append(question)
                    loadedCount += 1
                } else {
                    skippedCount += 1
                    print("⚠️ Skipped question in \(fileName): '\(questionJSON.text)' - Category: \(questionJSON.category), Difficulty: \(questionJSON.difficulty)")
                }
            }
            
            print("✅ Loaded \(loadedCount) questions from \(fileName).json" + (skippedCount > 0 ? " (skipped \(skippedCount))" : ""))
            
        } catch {
            print("❌ Error loading questions from \(fileName).json: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
    }
    
    private func convertToQuestion(_ json: QuestionJSON, expectedCategory: QuizCategory) -> Question? {
        // Convert string category to enum
        guard let category = mapCategory(json.category) else {
            print("⚠️ Unknown category: '\(json.category)'")
            return nil
        }
        
        // Validate category matches expected file
        if category != expectedCategory {
            print("⚠️ Category mismatch in file: Expected \(expectedCategory.rawValue), got \(category.rawValue)")
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
    
    // Reload specific category (useful for updates)
    func reloadCategory(_ category: QuizCategory) {
        guard let fileName = categoryFileNames[category] else {
            print("⚠️ No file mapping found for category: \(category.rawValue)")
            return
        }
        
        // Remove existing questions for this category
        allQuestions.removeAll { $0.category == category }
        
        // Reload from file
        loadQuestionsFromFile(fileName: fileName, expectedCategory: category)
        
        print("🔄 Reloaded category: \(category.rawValue)")
    }
    
    // Get statistics for a specific category
    func getCategoryStats(_ category: QuizCategory) -> [Difficulty: Int] {
        var stats: [Difficulty: Int] = [:]
        
        let categoryQuestions = allQuestions.filter { $0.category == category }
        
        for difficulty in Difficulty.allCases {
            let count = categoryQuestions.filter { $0.difficulty == difficulty }.count
            stats[difficulty] = count
        }
        
        return stats
    }
}
