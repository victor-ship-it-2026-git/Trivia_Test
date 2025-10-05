//
//  QuestionsManager.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

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
            Question(text: "What is the capital of France?", options: ["London", "Berlin", "Paris", "Madrid"], correctAnswer: 2, category: .geography, difficulty: .easy),
            Question(text: "Which continent is the largest?", options: ["Africa", "Asia", "Europe", "North America"], correctAnswer: 1, category: .geography, difficulty: .easy),
            Question(text: "What is the largest planet in our solar system?", options: ["Earth", "Mars", "Jupiter", "Saturn"], correctAnswer: 2, category: .science, difficulty: .easy),
            Question(text: "Who painted the Mona Lisa?", options: ["Van Gogh", "Da Vinci", "Picasso", "Monet"], correctAnswer: 1, category: .art, difficulty: .easy),
            Question(text: "What is the smallest prime number?", options: ["0", "1", "2", "3"], correctAnswer: 2, category: .math, difficulty: .easy),
        ]
        print("ℹ️ Loaded \(allQuestions.count) fallback questions")
    }
}
