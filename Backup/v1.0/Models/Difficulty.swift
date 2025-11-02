

import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case rookie = "Rookie"
    case amateur = "Amateur"
    case pro = "Pro"
    case master = "Master"
    case legend = "Legend"
    case genius = "Genius"
    
    var color: Color {
        switch self {
        case .rookie: return .green
        case .amateur: return .cyan
        case .pro: return .blue
        case .master: return .purple
        case .legend: return .orange
        case .genius: return .red
        }
    }
    
    var description: String {
        switch self {
        case .rookie: return "Perfect for beginners"
        case .amateur: return "Getting comfortable"
        case .pro: return "You know your stuff"
        case .master: return "Expert level challenge"
        case .legend: return "Only for the brave"
        case .genius: return "Ultimate brain teaser"
        }
    }
    
    var emoji: String {
        switch self {
        case .rookie: return "🌱"
        case .amateur: return "📚"
        case .pro: return "⚡️"
        case .master: return "👑"
        case .legend: return "🔥"
        case .genius: return "🧠"
        }
    }
    
    var pointsMultiplier: Int {
        switch self {
        case .rookie: return 1
        case .amateur: return 2
        case .pro: return 3
        case .master: return 4
        case .legend: return 5
        case .genius: return 6
        }
    }
}
