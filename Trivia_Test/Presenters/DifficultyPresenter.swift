
import SwiftUI
internal import Combine

class DifficultyPresenter: ObservableObject {
    @Published var selectedDifficulty: Difficulty = .rookie
    
    func selectDifficulty(_ difficulty: Difficulty) {
        selectedDifficulty = difficulty
    }
    
    func getAvailableQuestions(category: QuizCategory, difficulty: Difficulty) -> Int {
        return QuestionsManager.shared.getFilteredQuestions(
            category: category,
            difficulty: difficulty
        ).count
    }
}
