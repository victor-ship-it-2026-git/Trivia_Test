
import Foundation

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
                allQuestions = try decoder.decode([Question].self, from: data)
                print("✅ Successfully loaded \(allQuestions.count) questions from JSON")
            } catch {
                print("❌ Error loading questions from JSON: \(error)")
                loadFallbackQuestions()
            }
        } else {
            print("⚠️ questions.json not found, using fallback questions")
            loadFallbackQuestions()
        }
    }
    
    func getQuestions() -> [Question] {
        return allQuestions
    }
    
    func getFilteredQuestions(category: QuizCategory, difficulty: Difficulty) -> [Question] {
        var filtered = allQuestions
        
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        filtered = filtered.filter { $0.difficulty == difficulty }
        
        return filtered
    }
    
    private func loadFallbackQuestions() {
        allQuestions = [
            // Rookie
            Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, category: .geography, difficulty: .rookie),
            Question(text: "What color is the sky?", options: ["Green", "Blue", "Red", "Yellow"], correctAnswer: 1, category: .science, difficulty: .rookie),
            Question(text: "How many days in a week?", options: ["5", "6", "7", "8"], correctAnswer: 2, category: .math, difficulty: .rookie),
            
            // Amateur
            Question(text: "Which continent is the largest?", options: ["Africa", "Asia", "Europe", "North America"], correctAnswer: 1, category: .geography, difficulty: .amateur),
            Question(text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, category: .science, difficulty: .amateur),
            Question(text: "Who painted the Mona Lisa?", options: ["Van Gogh", "Da Vinci", "Picasso", "Monet"], correctAnswer: 1, category: .art, difficulty: .amateur),
            
            // Pro
            Question(text: "What is the longest river in the world?", options: ["Amazon", "Nile", "Yangtze", "Mississippi"], correctAnswer: 1, category: .geography, difficulty: .pro),
            Question(text: "Which element has the chemical symbol 'Au'?", options: ["Silver", "Gold", "Aluminum", "Argon"], correctAnswer: 1, category: .science, difficulty: .pro),
            Question(text: "In what year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctAnswer: 2, category: .history, difficulty: .pro),
            
            // Master
            Question(text: "What is the smallest country in the world?", options: ["Monaco", "Vatican City", "San Marino", "Liechtenstein"], correctAnswer: 1, category: .geography, difficulty: .master),
            Question(text: "What is the speed of light?", options: ["300,000 km/s", "150,000 km/s", "450,000 km/s", "600,000 km/s"], correctAnswer: 0, category: .science, difficulty: .master),
            Question(text: "Who wrote 'One Hundred Years of Solitude'?", options: ["Pablo Neruda", "Gabriel García Márquez", "Jorge Luis Borges", "Octavio Paz"], correctAnswer: 1, category: .literature, difficulty: .master),
            
            // Legend
            Question(text: "What is the capital of Kyrgyzstan?", options: ["Bishkek", "Tashkent", "Dushanbe", "Astana"], correctAnswer: 0, category: .geography, difficulty: .legend),
            Question(text: "What is the half-life of Carbon-14?", options: ["5,730 years", "10,000 years", "2,500 years", "15,000 years"], correctAnswer: 0, category: .science, difficulty: .legend),
            Question(text: "What year was the Magna Carta signed?", options: ["1215", "1315", "1415", "1515"], correctAnswer: 0, category: .history, difficulty: .legend),
            
            // Genius
            Question(text: "What is the Heisenberg Uncertainty Principle about?", options: ["Energy and time", "Position and momentum", "Mass and velocity", "Temperature and pressure"], correctAnswer: 1, category: .science, difficulty: .genius),
            Question(text: "Which mathematician proved Fermat's Last Theorem?", options: ["Andrew Wiles", "Grigori Perelman", "Terence Tao", "Maryam Mirzakhani"], correctAnswer: 0, category: .math, difficulty: .genius),
            Question(text: "What is the rarest naturally occurring element?", options: ["Astatine", "Francium", "Promethium", "Technetium"], correctAnswer: 0, category: .science, difficulty: .genius),
        ]
        print("ℹ️ Loaded \(allQuestions.count) fallback questions")
    }
}
