import SwiftUI

enum QuizCategory: String, CaseIterable, Codable {
    case all = "All Categories"
    case geography = "Geography"
    case science = "Science"
    case history = "History"
    case movies = "Movies"
    case math = "Math"
    case music = "Music"
    case sports = "Sports"
    case popCulture = "Pop Culture"
    case celebrities = "Celebrities"
    case the90s = "The 90s"
    case the2000s = "2000s Era"
    case genZ = "Gen Z"

    var emoji: String {
        switch self {
        case .all: return "🌟"
        case .geography: return "🌍"
        case .science: return "🔬"
        case .history: return "📜"
        case .movies: return "🎬"
        case .math: return "🔢"
        case .music: return "🎵"
        case .sports: return "⚽️"
        case .popCulture: return "🎭"
        case .celebrities: return "⭐️"
        case .the90s: return "📼"
        case .the2000s: return "📱"
        case .genZ: return "🔥"
        }
    }
}
