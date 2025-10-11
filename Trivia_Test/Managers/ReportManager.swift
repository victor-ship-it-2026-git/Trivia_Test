//
//  ReportManager.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation
import FirebaseDatabase
internal import Combine

class ReportManager: ObservableObject {
    static let shared = ReportManager()
    
    private let database = Database.database().reference()
    @Published var isSubmitting = false
    @Published var submitError: String?
    @Published var submitSuccess = false
    
    private init() {}
    
    // MARK: - Submit Report
    
    func submitReport(
        question: Question,
        reason: ReportReason,
        additionalDetails: String,
        reporterName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        isSubmitting = true
        
        let reportRef = database.child("question_reports").childByAutoId()
        
        let reportData: [String: Any] = [
            "questionText": question.text,
            "options": question.options,
            "correctAnswer": question.correctAnswer,
            "category": question.category.rawValue,
            "difficulty": question.difficulty.rawValue,
            "reportReason": reason.rawValue,
            "additionalDetails": additionalDetails,
            "reporterName": reporterName,
            "timestamp": Date().timeIntervalSince1970,
            "status": "pending" // pending, reviewed, resolved
        ]
        
        reportRef.setValue(reportData) { [weak self] error, _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                if let error = error {
                    self.submitError = error.localizedDescription
                    completion(.failure(error))
                } else {
                    self.submitSuccess = true
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Get All Reports (Admin use)
    
    func getAllReports(completion: @escaping ([QuestionReport]) -> Void) {
        database.child("question_reports")
            .queryOrdered(byChild: "timestamp")
            .observeSingleEvent(of: .value) { snapshot in
                var reports: [QuestionReport] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any],
                       let report = QuestionReport.from(dict: dict, id: snapshot.key) {
                        reports.append(report)
                    }
                }
                
                // Sort by most recent first
                reports.sort { $0.timestamp > $1.timestamp }
                
                DispatchQueue.main.async {
                    completion(reports)
                }
            }
    }
    
    // MARK: - Get Pending Reports Count
    
    func getPendingReportsCount(completion: @escaping (Int) -> Void) {
        database.child("question_reports")
            .queryOrdered(byChild: "status")
            .queryEqual(toValue: "pending")
            .observeSingleEvent(of: .value) { snapshot in
                DispatchQueue.main.async {
                    completion(Int(snapshot.childrenCount))
                }
            }
    }
}

// MARK: - Report Models

enum ReportReason: String, CaseIterable {
    case wrongAnswer = "Wrong Answer"
    case unclearQuestion = "Unclear Question"
    case multipleCorrect = "Multiple Correct Answers"
    case typo = "Typo/Grammar Error"
    case outdated = "Outdated Information"
    case offensive = "Offensive Content"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .wrongAnswer: return "xmark.circle"
        case .unclearQuestion: return "questionmark.circle"
        case .multipleCorrect: return "checkmark.circle.badge.questionmark"
        case .typo: return "text.badge.xmark"
        case .outdated: return "clock.badge.exclamationmark"
        case .offensive: return "exclamationmark.triangle"
        case .other: return "ellipsis.circle"
        }
    }
    
    var description: String {
        switch self {
        case .wrongAnswer: return "The marked answer is incorrect"
        case .unclearQuestion: return "Question is confusing or ambiguous"
        case .multipleCorrect: return "More than one answer could be correct"
        case .typo: return "There's a spelling or grammar mistake"
        case .outdated: return "Information is no longer accurate"
        case .offensive: return "Content is inappropriate or offensive"
        case .other: return "Something else is wrong"
        }
    }
}

struct QuestionReport: Identifiable {
    let id: String
    let questionText: String
    let options: [String]
    let correctAnswer: Int
    let category: String
    let difficulty: String
    let reportReason: String
    let additionalDetails: String
    let reporterName: String
    let timestamp: Date
    let status: String
    
    static func from(dict: [String: Any], id: String) -> QuestionReport? {
        guard let questionText = dict["questionText"] as? String,
              let options = dict["options"] as? [String],
              let correctAnswer = dict["correctAnswer"] as? Int,
              let category = dict["category"] as? String,
              let difficulty = dict["difficulty"] as? String,
              let reportReason = dict["reportReason"] as? String,
              let additionalDetails = dict["additionalDetails"] as? String,
              let reporterName = dict["reporterName"] as? String,
              let timestamp = dict["timestamp"] as? TimeInterval,
              let status = dict["status"] as? String else {
            return nil
        }
        
        return QuestionReport(
            id: id,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswer,
            category: category,
            difficulty: difficulty,
            reportReason: reportReason,
            additionalDetails: additionalDetails,
            reporterName: reporterName,
            timestamp: Date(timeIntervalSince1970: timestamp),
            status: status
        )
    }
}