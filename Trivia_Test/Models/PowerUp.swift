import Foundation

enum PowerUpType: String, Codable, CaseIterable {
    case doublePoints = "Double Points"
    case freezeTime = "Freeze Time"
    case autoCorrect = "Auto Correct"
    
    var icon: String {
        switch self {
        case .doublePoints: return "star.fill"
        case .freezeTime: return "snowflake"
        case .autoCorrect: return "checkmark.shield.fill"
        }
    }
    
    var description: String {
        switch self {
        case .doublePoints: return "Next question worth 2x points"
        case .freezeTime: return "Timer won't count down"
        case .autoCorrect: return "Automatically correct next wrong answer"
        }
    }
}

struct PowerUp: Identifiable, Codable {
    let id: UUID
    let type: PowerUpType
    var isActive: Bool
    var quantity: Int
    
    init(type: PowerUpType, quantity: Int = 0) {
        self.id = UUID()
        self.type = type
        self.isActive = false
        self.quantity = quantity
    }
}
