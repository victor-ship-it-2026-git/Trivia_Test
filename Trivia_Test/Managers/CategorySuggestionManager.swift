import Foundation
import FirebaseDatabase
internal import Combine

@MainActor
class CategorySuggestionManager: ObservableObject {
    static let shared = CategorySuggestionManager()
    
    private let database = Database.database().reference()
    @Published var isSubmitting = false
    @Published var submitError: String?
    @Published var submitSuccess = false
    
    private init() {}
    
    // Submit Category Suggestion
    
    func submitSuggestion(
        categoryName: String,
        userName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard !categoryName.isEmpty else {
            submitError = "Please enter a category name"
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Category name is empty"])))
            return
        }
        
        isSubmitting = true
        
        let suggestion = CategorySuggestion(categoryName: categoryName, userName: userName)
        let suggestionRef = database.child("category_suggestions").childByAutoId()
        
        let suggestionData: [String: Any] = [
            "id": suggestion.id,
            "categoryName": suggestion.categoryName,
            "userName": suggestion.userName,
            "timestamp": suggestion.timestamp.timeIntervalSince1970,
            "status": suggestion.status
        ]
        
        suggestionRef.setValue(suggestionData) { [weak self] error, _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isSubmitting = false
                
                if let error = error {
                    self.submitError = error.localizedDescription
                    completion(.failure(error))
                } else {
                    self.submitSuccess = true
                    
                    // Log analytics
                    AnalyticsManager.shared.logCustomEvent(
                        eventName: "category_suggestion_submitted",
                        parameters: [
                            "category_name": categoryName,
                            "user_name": userName
                        ]
                    )
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    // Get All Suggestions (for admin view)
    
    func getAllSuggestions(completion: @escaping ([CategorySuggestion]) -> Void) {
        database.child("category_suggestions")
            .queryOrdered(byChild: "timestamp")
            .observeSingleEvent(of: .value) { snapshot in
                var suggestions: [CategorySuggestion] = []
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let dict = snapshot.value as? [String: Any],
                       let categoryName = dict["categoryName"] as? String,
                       let userName = dict["userName"] as? String {
                        
                        let suggestion = CategorySuggestion(categoryName: categoryName, userName: userName)
                        suggestions.append(suggestion)
                    }
                }
                
                // Note: Sort by most recent first
                suggestions.sort { $0.timestamp > $1.timestamp }
                
                DispatchQueue.main.async {
                    completion(suggestions)
                }
            }
    }
}
