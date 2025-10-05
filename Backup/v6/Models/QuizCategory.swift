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
        }
    }
}
