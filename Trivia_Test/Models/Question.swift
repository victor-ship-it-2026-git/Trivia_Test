//
//  Question.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import Foundation

struct Question: Codable {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let category: QuizCategory
    let difficulty: Difficulty
}
