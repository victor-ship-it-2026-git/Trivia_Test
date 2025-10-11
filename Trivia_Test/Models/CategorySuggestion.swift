//
//  CategorySuggestion.swift
//  Trivia_Test
//
//  Created by Win on 11/10/2568 BE.
//


//
//  CategorySuggestion.swift
//  Trivia_Test
//
//  Created by Win
//

import Foundation

struct CategorySuggestion: Identifiable, Codable {
    let id: String
    let categoryName: String
    let userName: String
    let timestamp: Date
    let status: String // "pending", "approved", "rejected"
    
    init(categoryName: String, userName: String) {
        self.id = UUID().uuidString
        self.categoryName = categoryName
        self.userName = userName
        self.timestamp = Date()
        self.status = "pending"
    }
}
