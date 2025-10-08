//
//  DifficultyUnlockManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import Combine

class DifficultyUnlockManager: ObservableObject {
    static let shared = DifficultyUnlockManager()
    private let defaults = UserDefaults.standard
    
    @Published var unlockedDifficulties: [String: [Difficulty]] = [:]
    
    private init() {
        loadUnlockedDifficulties()
    }
    
    // Key format: "difficulty_unlocked_{category}_{difficulty}"
    private func getKey(category: QuizCategory, difficulty: Difficulty) -> String {
        return "difficulty_unlocked_\(category.rawValue)_\(difficulty.rawValue)"
    }
    
    // Load all unlocked difficulties for all categories
    func loadUnlockedDifficulties() {
        for category in QuizCategory.allCases {
            var unlocked: [Difficulty] = [.rookie] // Rookie is always unlocked
            
            for difficulty in Difficulty.allCases where difficulty != .rookie {
                let key = getKey(category: category, difficulty: difficulty)
                if defaults.bool(forKey: key) {
                    unlocked.append(difficulty)
                }
            }
            
            unlockedDifficulties[category.rawValue] = unlocked
        }
    }
    
    // Check if a difficulty is unlocked for a category
    func isDifficultyUnlocked(category: QuizCategory, difficulty: Difficulty) -> Bool {
        // Rookie is always unlocked
        if difficulty == .rookie {
            return true
        }
        
        let key = getKey(category: category, difficulty: difficulty)
        return defaults.bool(forKey: key)
    }
    
    // Check if difficulty is available (either unlocked or next in sequence)
    func isDifficultyAvailable(category: QuizCategory, difficulty: Difficulty) -> Bool {
        let difficulties = Difficulty.allCases
        guard let currentIndex = difficulties.firstIndex(of: difficulty) else {
            return false
        }
        
        // Rookie is always available
        if currentIndex == 0 {
            return true
        }
        
        // Check if previous difficulty is unlocked
        let previousDifficulty = difficulties[currentIndex - 1]
        return isDifficultyUnlocked(category: category, difficulty: previousDifficulty)
    }
    
    // Unlock the next difficulty level for a category
    func unlockNextDifficulty(category: QuizCategory, completedDifficulty: Difficulty) {
        let difficulties = Difficulty.allCases
        guard let currentIndex = difficulties.firstIndex(of: completedDifficulty),
              currentIndex < difficulties.count - 1 else {
            // Already at max difficulty
            return
        }
        
        let nextDifficulty = difficulties[currentIndex + 1]
        let key = getKey(category: category, difficulty: nextDifficulty)
        
        if !defaults.bool(forKey: key) {
            defaults.set(true, forKey: key)
            print("🔓 Unlocked \(nextDifficulty.rawValue) for \(category.rawValue)")
            loadUnlockedDifficulties()
        }
    }
    
    // Get the highest unlocked difficulty for a category
    func getHighestUnlockedDifficulty(category: QuizCategory) -> Difficulty {
        var highest: Difficulty = .rookie
        
        for difficulty in Difficulty.allCases {
            if isDifficultyUnlocked(category: category, difficulty: difficulty) {
                highest = difficulty
            }
        }
        
        return highest
    }
    
    // Reset all progress (for testing)
    func resetAllProgress() {
        for category in QuizCategory.allCases {
            for difficulty in Difficulty.allCases where difficulty != .rookie {
                let key = getKey(category: category, difficulty: difficulty)
                defaults.removeObject(forKey: key)
            }
        }
        loadUnlockedDifficulties()
        print("🔄 Reset all difficulty progress")
    }
}