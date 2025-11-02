
import SwiftUI
internal import Combine


class CategoryPresenter: ObservableObject {
    @Published var selectedCategory: QuizCategory = .all
    
    func selectCategory(_ category: QuizCategory) {
        selectedCategory = category
    }
}
