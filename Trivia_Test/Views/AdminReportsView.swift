//
//  AdminReportsView.swift
//  Trivia_Test
//
//  Created by Win
//

import SwiftUI

struct AdminReportsView: View {
    @StateObject private var reportManager = ReportManager.shared
    @State private var reports: [QuestionReport] = []
    @State private var isLoading = true
    @State private var filterStatus: ReportStatus = .all
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    enum ReportStatus: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case reviewed = "Reviewed"
        case resolved = "Resolved"
    }
    
    var filteredReports: [QuestionReport] {
        if filterStatus == .all {
            return reports
        }
        return reports.filter { $0.status == filterStatus.rawValue.lowercased() }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ReportStatus.allCases, id: \.self) { status in
                                FilterTab(
                                    title: status.rawValue,
                                    count: getCount(for: status),
                                    isSelected: filterStatus == status,
                                    action: { filterStatus = status }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color.dynamicCardBackground)
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading reports...")
                            .font(.subheadline)
                            .foregroundColor(.dynamicSecondaryText)
                            .padding(.top)
                        Spacer()
                    } else if filteredReports.isEmpty {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("No Reports")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.dynamicText)
                            Text(filterStatus == .pending ? 
                                "All caught up! No pending reports." :
                                "No \(filterStatus.rawValue.lowercased()) reports found.")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredReports) { report in
                                    ReportCard(report: report)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Question Reports")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                leading: Button("Close") { dismiss() },
                trailing: Button(action: loadReports) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                loadReports()
            }
        }
    }
    
    private func loadReports() {
        isLoading = true
        reportManager.getAllReports { fetchedReports in
            reports = fetchedReports
            isLoading = false
        }
    }
    
    private func getCount(for status: ReportStatus) -> Int {
        if status == .all {
            return reports.count
        }
        return reports.filter { $0.status == status.rawValue.lowercased() }.count
    }
}

// MARK: - Filter Tab
struct FilterTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Circle().fill(isSelected ? Color.white.opacity(0.3) : Color.gray))
                }
            }
            .foregroundColor(isSelected ? .white : .dynamicText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.2))
            )
        }
    }
}

// MARK: - Report Card
struct ReportCard: View {
    let report: QuestionReport
    @State private var isExpanded = false
    @Environment(\.colorScheme) var colorScheme
    
    var statusColor: Color {
        switch report.status {
        case "pending": return .orange
        case "reviewed": return .blue
        case "resolved": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: getReasonIcon(report.reportReason))
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.reportReason)
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Text(formatDate(report.timestamp))
                        .font(.caption)
                        .foregroundColor(.dynamicSecondaryText)
                }
                
                Spacer()
                
                // Status Badge
                Text(report.status.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(statusColor))
                
                // Expand/Collapse
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            
            // Category & Difficulty
            HStack(spacing: 8) {
                Label(report.category, systemImage: "folder")
                    .font(.caption)
                    .foregroundColor(.dynamicText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.2))
                    .cornerRadius(6)
                
                Label(report.difficulty, systemImage: "star")
                    .font(.caption)
                    .foregroundColor(.dynamicText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor(report.difficulty).opacity(colorScheme == .dark ? 0.25 : 0.2))
                    .cornerRadius(6)
            }
            
            // Question Preview
            Text(report.questionText)
                .font(.body)
                .foregroundColor(.dynamicText)
                .lineLimit(isExpanded ? nil : 2)
            
            if isExpanded {
                Divider()
                
                // Options
                VStack(alignment: .leading, spacing: 8) {
                    Text("Options:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.dynamicSecondaryText)
                    
                    ForEach(0..<report.options.count, id: \.self) { index in
                        HStack {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundColor(.dynamicSecondaryText)
                            
                            Text(report.options[index])
                                .font(.caption)
                                .foregroundColor(.dynamicText)
                            
                            if index == report.correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Reporter Info
                if !report.additionalDetails.isEmpty && report.additionalDetails != "No additional details provided" {
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Additional Details:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.dynamicSecondaryText)
                        
                        Text(report.additionalDetails)
                            .font(.caption)
                            .foregroundColor(.dynamicText)
                    }
                }
                
                // Reporter Name
                Text("Reported by: \(report.reporterName)")
                    .font(.caption)
                    .foregroundColor(.dynamicSecondaryText)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dynamicCardBackground)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5)
        )
    }
    
    private func getReasonIcon(_ reason: String) -> String {
        switch reason {
        case "Wrong Answer": return "xmark.circle"
        case "Unclear Question": return "questionmark.circle"
        case "Multiple Correct Answers": return "checkmark.circle.badge.questionmark"
        case "Typo/Grammar Error": return "text.badge.xmark"
        case "Outdated Information": return "clock.badge.exclamationmark"
        case "Offensive Content": return "exclamationmark.triangle"
        default: return "ellipsis.circle"
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Rookie": return .green
        case "Amateur": return .cyan
        case "Pro": return .blue
        case "Master": return .purple
        case "Legend": return .orange
        case "Genius": return .red
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
struct AdminReportsView_Previews: PreviewProvider {
    static var previews: some View {
        AdminReportsView()
    }
}