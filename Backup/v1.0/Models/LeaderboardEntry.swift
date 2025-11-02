
import Foundation

struct LeaderboardEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let playerName: String
    let score: Int
    let totalQuestions: Int
    let category: String
    let difficulty: String
    let date: Date
    
    var percentage: Int {
        guard totalQuestions > 0 else { return 0 }
        return (score * 100) / totalQuestions
    }
    

    static func == (lhs: LeaderboardEntry, rhs: LeaderboardEntry) -> Bool {
        return lhs.id == rhs.id &&
               lhs.playerName == rhs.playerName &&
               lhs.score == rhs.score &&
               lhs.totalQuestions == rhs.totalQuestions &&
               lhs.category == rhs.category &&
               lhs.difficulty == rhs.difficulty
    }
}
