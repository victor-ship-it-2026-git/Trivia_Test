
import Foundation

struct Question: Codable {
    let text: String
    let options: [String]
    let correctAnswer: Int
    let category: QuizCategory
    let difficulty: Difficulty
}
