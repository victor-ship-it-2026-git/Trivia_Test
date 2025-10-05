//
//  DifficultyPresenter.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI
internal import Combine

class DifficultyPresenter: ObservableObject {
    @Published var selectedDifficulty: Difficulty = .easy
    
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
