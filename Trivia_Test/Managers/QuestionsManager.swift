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
    
    // Cache management
    private var questionCache: [String: [Question]] = [:]
    private var cacheAccessOrder: [String] = [] // Track access order for LRU
    private let cacheLimit = 200 // Only keep 200 questions in memory
    
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
        // No initial loading - load on demand
        print("📚 QuestionsManager initialized with lazy loading")
    }
    
    // MARK: - Public Methods
    
    func getFilteredQuestions(category: QuizCategory, difficulty: Difficulty) -> [Question] {
        let key = makeCacheKey(category: category, difficulty: difficulty)
        
        // Check cache first
        if let cached = questionCache[key] {
            updateCacheAccess(key: key)
            print("✅ Cache hit for \(key): \(cached.count) questions")
            return cached
        }
        
        // Load only needed questions
        print("📂 Cache miss for \(key), loading from file...")
        let questions = loadQuestionsForCategory(category, difficulty: difficulty)
        
        // Add to cache with LRU management
        addToCache(key: key, questions: questions)
        
        return questions
    }
    
    func getQuestions() -> [Question] {
        // For diagnostic purposes - load all questions
        var allQuestions: [Question] = []
        
        for category in QuizCategory.allCases {
            for difficulty in Difficulty.allCases {
                let questions = getFilteredQuestions(category: category, difficulty: difficulty)
                allQuestions.append(contentsOf: questions)
            }
        }
        
        return allQuestions
    }
    
    // MARK: - Cache Management
    
    private func makeCacheKey(category: QuizCategory, difficulty: Difficulty) -> String {
        return "\(category.rawValue)_\(difficulty.rawValue)"
    }
    
    private func updateCacheAccess(key: String) {
        // Move key to end (most recently used)
        if let index = cacheAccessOrder.firstIndex(of: key) {
            cacheAccessOrder.remove(at: index)
        }
        cacheAccessOrder.append(key)
    }
    
    private func addToCache(key: String, questions: [Question]) {
        // Implement LRU eviction if cache is full
        if questionCache.count >= cacheLimit {
            evictLeastRecentlyUsed()
        }
        
        questionCache[key] = questions
        updateCacheAccess(key: key)
        
        print("💾 Added to cache: \(key) (\(questions.count) questions)")
        print("📊 Cache size: \(questionCache.count)/\(cacheLimit)")
    }
    
    private func evictLeastRecentlyUsed() {
        guard let lruKey = cacheAccessOrder.first else { return }
        
        questionCache.removeValue(forKey: lruKey)
        cacheAccessOrder.removeFirst()
        
        print("🗑️ Evicted from cache: \(lruKey)")
    }
    
    func clearCache() {
        questionCache.removeAll()
        cacheAccessOrder.removeAll()
        print("🧹 Cache cleared")
    }
    
    // MARK: - Loading Methods
    
    private func loadQuestionsForCategory(_ category: QuizCategory, difficulty: Difficulty) -> [Question] {
        guard let fileName = categoryFileNames[category] else {
            print("⚠️ No file mapping found for category: \(category.rawValue)")
            return []
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("⚠️ Warning: \(fileName).json not found")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionsJSON = try decoder.decode([QuestionJSON].self, from: data)
            
            // Filter by difficulty and convert
            let questions = questionsJSON.compactMap { questionJSON -> Question? in
                guard let question = convertToQuestion(questionJSON, expectedCategory: category) else {
                    return nil
                }
                return question.difficulty == difficulty ? question : nil
            }
            
            print("✅ Loaded \(questions.count) questions for \(category.rawValue) - \(difficulty.rawValue)")
            return questions
            
        } catch {
            print("❌ Error loading questions from \(fileName).json: \(error)")
            return []
        }
    }
    
    private func convertToQuestion(_ json: QuestionJSON, expectedCategory: QuizCategory) -> Question? {
        // Convert string category to enum
        guard let category = mapCategory(json.category) else {
            return nil
        }
        
        // Validate category matches expected file
        if category != expectedCategory {
            return nil
        }
        
        // Convert string difficulty to enum
        guard let difficulty = mapDifficulty(json.difficulty) else {
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
    
    // MARK: - Utility Methods
    
    func reloadCategory(_ category: QuizCategory) {
        // Clear cache entries for this category
        let keysToRemove = cacheAccessOrder.filter { $0.hasPrefix(category.rawValue) }
        for key in keysToRemove {
            questionCache.removeValue(forKey: key)
            if let index = cacheAccessOrder.firstIndex(of: key) {
                cacheAccessOrder.remove(at: index)
            }
        }
        
        print("🔄 Cleared cache for category: \(category.rawValue)")
    }
    
    func getCategoryStats(_ category: QuizCategory) -> [Difficulty: Int] {
        var stats: [Difficulty: Int] = [:]
        
        for difficulty in Difficulty.allCases {
            let questions = getFilteredQuestions(category: category, difficulty: difficulty)
            stats[difficulty] = questions.count
        }
        
        return stats
    }
    
    func printCacheStats() {
        print("\n=== CACHE STATISTICS ===")
        print("Total cached combinations: \(questionCache.count)/\(cacheLimit)")
        print("Cache access order:")
        for (index, key) in cacheAccessOrder.enumerated() {
            let count = questionCache[key]?.count ?? 0
            print("  \(index + 1). \(key): \(count) questions")
        }
        print("========================\n")
    }
}
