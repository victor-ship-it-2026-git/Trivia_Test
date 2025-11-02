
import Foundation

struct DailyChallenge: Identifiable, Codable {
    let id: UUID
    let date: Date
    let challengeType: ChallengeType
    let targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    let reward: ChallengeReward
    
    var progressPercentage: Double {
        return min(Double(currentProgress) / Double(targetValue), 1.0)
    }
    
    init(type: ChallengeType, targetValue: Int, reward: ChallengeReward) {
        self.id = UUID()
        self.date = Date()
        self.challengeType = type
        self.targetValue = targetValue
        self.currentProgress = 0
        self.isCompleted = false
        self.reward = reward
    }
}

enum ChallengeType: String, Codable {
    case answerCorrectly = "Answer Correctly"
    case perfectStreak = "Perfect Streak"
    case completeQuizzes = "Complete Quizzes"
    case speedRun = "Speed Run"
    
    var icon: String {
        switch self {
        case .answerCorrectly: return "checkmark.circle.fill"
        case .perfectStreak: return "flame.fill"
        case .completeQuizzes: return "flag.checkered"
        case .speedRun: return "timer"
        }
    }
    
    var description: String {
        switch self {
        case .answerCorrectly: return "Answer questions correctly"
        case .perfectStreak: return "Maintain a perfect streak"
        case .completeQuizzes: return "Complete full quizzes"
        case .speedRun: return "Answer within 10 seconds"
        }
    }
}

struct ChallengeReward: Codable {
    let lifelines: [LifelineType: Int]
    let coins: Int
    
    init(lifelines: [LifelineType: Int] = [:], coins: Int = 0) {
        self.lifelines = lifelines
        self.coins = coins
    }
}
