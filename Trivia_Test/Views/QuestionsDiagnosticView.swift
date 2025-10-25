import SwiftUI

// Added temporarily to debug your questions
struct QuestionsDiagnosticView: View {
    private let questionsManager = QuestionsManager.shared
    @State private var diagnosticInfo: String = "Loading..."
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Questions Diagnostic")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text(diagnosticInfo)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .onAppear {
                runDiagnostics()
            }
        }
    }
    
    private func runDiagnostics() {
        let allQuestions = questionsManager.getQuestions()
        var report = ""
        
        report += "📊 TOTAL QUESTIONS: \(allQuestions.count)\n\n"
        
        // Check questions by category
        report += "=== QUESTIONS BY CATEGORY ===\n"
        for category in QuizCategory.allCases {
            let categoryQuestions = allQuestions.filter { $0.category == category }
            report += "\n\(category.emoji) \(category.rawValue): \(categoryQuestions.count) questions\n"
            
            // Break down by difficulty
            for difficulty in Difficulty.allCases {
                let count = categoryQuestions.filter { $0.difficulty == difficulty }.count
                report += "  - \(difficulty.emoji) \(difficulty.rawValue): \(count)\n"
            }
        }
        
        // Check questions by difficulty
        report += "\n=== QUESTIONS BY DIFFICULTY ===\n"
        for difficulty in Difficulty.allCases {
            let count = allQuestions.filter { $0.difficulty == difficulty }.count
            report += "\(difficulty.emoji) \(difficulty.rawValue): \(count) questions\n"
        }
        
        // Show sample questions
        report += "\n=== SAMPLE QUESTIONS (First 3) ===\n"
        for (index, question) in allQuestions.prefix(3).enumerated() {
            report += "\n[\(index + 1)] \(question.category.rawValue) - \(question.difficulty.rawValue)\n"
            report += "Q: \(question.text)\n"
        }
        
        // Check for missing combinations
        report += "\n=== MISSING COMBINATIONS ===\n"
        var missingCount = 0
        for category in QuizCategory.allCases {
            for difficulty in Difficulty.allCases {
                let count = allQuestions.filter { $0.category == category && $0.difficulty == difficulty }.count
                if count == 0 {
                    report += "⚠️ NO questions for \(category.rawValue) - \(difficulty.rawValue)\n"
                    missingCount += 1
                }
            }
        }
        
        if missingCount == 0 {
            report += "✅ All category/difficulty combinations have questions!\n"
        } else {
            report += "\n⚠️ Found \(missingCount) missing combinations\n"
        }
        
        diagnosticInfo = report
    }
}

