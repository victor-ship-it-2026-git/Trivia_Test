
import SwiftUI
internal import Combine

class DifficultyPresenter: ObservableObject {
    @Published var selectedDifficulty: Difficulty = .rookie
    
    func selectDifficulty(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
    }
    
    func getAvailableQuestions(category: QuizCategory, difficulty: Difficulty) -> Int {
           let allQuestions = QuestionsManager.shared.getFilteredQuestions(
               category: category,
               difficulty: difficulty
           ).count
           // Show maximum of 50 questions
           return min(allQuestions, 50)
       }
}
