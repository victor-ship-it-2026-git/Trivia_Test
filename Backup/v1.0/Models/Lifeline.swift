import Foundation

enum LifelineType: String, Codable, CaseIterable {
    case fiftyFifty = "50/50"
    case skip = "Skip"
    case extraTime = "+15 Sec"
    
    var icon: String {
        switch self {
        case .fiftyFifty: return "percent"
        case .skip: return "forward.fill"
        case .extraTime: return "clock.badge.plus"
        }
    }
    
    var description: String {
        switch self {
        case .fiftyFifty: return "Remove 2 wrong answers"
        case .skip: return "Skip this question"
        case .extraTime: return "Add 15 seconds"
        }
    }
    
    var color: String {
        switch self {
        case .fiftyFifty: return "blue"
        case .skip: return "orange"
        case .extraTime: return "green"
        }
    }
}

struct Lifeline: Identifiable, Codable {
    let id: UUID
    let type: LifelineType
    var quantity: Int
    
    init(type: LifelineType, quantity: Int = 1) {
        self.id = UUID()
        self.type = type
        self.quantity = quantity
    }
}
