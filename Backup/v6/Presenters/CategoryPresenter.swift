//
//  CategoryPresenter.swift
//  Trivia_Test
//
//  Created by Win on 4/10/2568 BE.
//

import SwiftUI
internal import Combine


class CategoryPresenter: ObservableObject {
    @Published var selectedCategory: QuizCategory = .all
    
    func selectCategory(_ category: QuizCategory) {
        selectedCategory = category
    }
}
