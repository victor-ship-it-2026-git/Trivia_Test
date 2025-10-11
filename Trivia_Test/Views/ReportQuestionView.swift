//
//  ReportQuestionView.swift
//  Trivia_Test
//
//  Created by Win on 11/10/2568 BE.
//


//
//  ReportQuestionView.swift
//  Trivia_Test
//
//  Created by Win
//

import SwiftUI

struct ReportQuestionView: View {
    let question: Question
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var reportManager = ReportManager.shared
    
    @State private var selectedReason: ReportReason = .wrongAnswer
    @State private var additionalDetails: String = ""
    @State private var reporterName: String = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header Info
                        VStack(spacing: 15) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)
                            
                            Text("Report Question")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.dynamicText)
                            
                            Text("Help us improve! Let us know what's wrong with this question.")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Question Preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Question:")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.dynamicSecondaryText)
                            
                            Text(question.text)
                                .font(.body)
                                .foregroundColor(.dynamicText)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.dynamicCardBackground)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            
                            Text("Marked Answer: \(question.options[question.correctAnswer])")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        // Report Reason Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("What's the issue?")
                                .font(.headline)
                                .foregroundColor(.dynamicText)
                            
                            ForEach(ReportReason.allCases, id: \.self) { reason in
                                ReportReasonButton(
                                    reason: reason,
                                    isSelected: selectedReason == reason,
                                    action: { selectedReason = reason }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Additional Details
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Additional Details (Optional)")
                                .font(.headline)
                                .foregroundColor(.dynamicText)
                            
                            Text("Please provide more information if needed")
                                .font(.caption)
                                .foregroundColor(.dynamicSecondaryText)
                            
                            TextEditor(text: $additionalDetails)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.dynamicCardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Reporter Name
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Name (Optional)")
                                .font(.headline)
                                .foregroundColor(.dynamicText)
                            
                            TextField("Enter your name", text: $reporterName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        .padding(.horizontal)
                        
                        // Submit Button
                        Button(action: submitReport) {
                            HStack(spacing: 10) {
                                if reportManager.isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(reportManager.isSubmitting ? "Submitting..." : "Submit Report")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.orange, Color.red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .disabled(reportManager.isSubmitting)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Report Submitted!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for helping us improve! We'll review this question.")
            }
            .alert("Error", isPresented: .constant(reportManager.submitError != nil)) {
                Button("OK") {
                    reportManager.submitError = nil
                }
            } message: {
                if let error = reportManager.submitError {
                    Text(error)
                }
            }
        }
    }
    
    private func submitReport() {
        HapticManager.shared.light()
        
        reportManager.submitReport(
            question: question,
            reason: selectedReason,
            additionalDetails: additionalDetails.isEmpty ? "No additional details provided" : additionalDetails,
            reporterName: reporterName.isEmpty ? "Anonymous" : reporterName
        ) { result in
            switch result {
            case .success:
                showSuccess = true
            case .failure:
                // Error is handled by alert
                break
            }
        }
    }
}

// MARK: - Report Reason Button
struct ReportReasonButton: View {
    let reason: ReportReason
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            HStack(spacing: 15) {
                Image(systemName: reason.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .orange : .gray)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(reason.rawValue)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.dynamicText)
                    
                    Text(reason.description)
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? 
                        Color.orange.opacity(colorScheme == .dark ? 0.2 : 0.1) :
                        Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview
struct ReportQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        ReportQuestionView(
            question: Question(
                text: "What is the capital of France?",
                options: ["London", "Berlin", "Paris", "Madrid"],
                correctAnswer: 2,
                category: .geography,
                difficulty: .rookie
            )
        )
    }
}
