//
//  QuizCategory.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

enum QuizCategory: String, CaseIterable, Codable {
    case all = "All Categories"
    case geography = "Geography"
    case science = "Science"
    case history = "History"
    case art = "Art"
    case literature = "Literature"
    case math = "Math"
    case sports = "Sports"
    case movies = "Movies"
<<<<<<< HEAD
    case popCulture = "Pop Culture"  // NEW: Added Pop Culture
=======
<<<<<<< HEAD
=======
    case popCulture = "Pop Culture"  // NEW: Added Pop Culture
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
    
    var emoji: String {
        switch self {
        case .all: return "🌟"
        case .geography: return "🌍"
        case .science: return "🔬"
        case .history: return "📜"
        case .art: return "🎨"
        case .literature: return "📚"
        case .math: return "🔢"
        case .sports: return "⚽️"
        case .movies: return "🎬"
<<<<<<< HEAD
        case .popCulture: return "🎭"  // NEW: Added emoji for Pop Culture
=======
<<<<<<< HEAD
=======
        case .popCulture: return "🎭"  // NEW: Added emoji for Pop Culture
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
        }
    }
}
