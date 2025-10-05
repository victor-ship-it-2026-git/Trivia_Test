//
//  Streak.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//


import Foundation

struct Streak: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCorrectAnswers: Int
    
    var multiplier: Int {
        switch currentStreak {
        case 0...2: return 1
        case 3...4: return 2
        case 5...7: return 3
        case 8...9: return 4
        default: return 5
        }
    }
    
    var emoji: String {
        switch currentStreak {
        case 0...2: return ""
        case 3...4: return "🔥"
        case 5...7: return "🔥🔥"
        case 8...9: return "🔥🔥🔥"
        default: return "🔥🔥🔥🔥"
        }
    }
    
    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalCorrectAnswers = 0
    }
    
    mutating func incrementStreak() {
        currentStreak += 1
        totalCorrectAnswers += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    mutating func resetStreak() {
        currentStreak = 0
    }
}
