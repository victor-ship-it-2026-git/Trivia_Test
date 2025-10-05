//
//  LeaderboardEntry.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//
import Foundation

struct LeaderboardEntry: Identifiable, Codable {
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
}
