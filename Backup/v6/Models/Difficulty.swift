//
//  Difficulty.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Perfect for beginners"
        case .medium: return "For experienced players"
        case .hard: return "Ultimate challenge"
        }
    }
}
