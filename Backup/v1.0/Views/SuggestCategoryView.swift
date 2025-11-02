
import SwiftUI

struct SuggestCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var suggestionManager = CategorySuggestionManager.shared
    
    @State private var categoryName: String = ""
    @State private var userName: String = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Text("💡")
                                .font(.system(size: 70))
                            
                            Text("Suggest a Category")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.dynamicText)
                            
                            Text("Help us expand! Share your ideas for new quiz categories.")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        
                        // Form
                        VStack(alignment: .leading, spacing: 20) {
                            // Category Name Input
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Category Name *")
                                    .font(.headline)
                                    .foregroundColor(.dynamicText)
                                
                                TextField("e.g., Music, Technology, Astronomy", text: $categoryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                            
                            // Your Name Input
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your Name (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.dynamicText)
                                
                                TextField("Enter your name", text: $userName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.words)
                            }
                            
                            // Info Box
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Your suggestion will be reviewed")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.dynamicText)
                                    
                                    Text("If approved, your category will be added to the game in a future update!")
                                        .font(.caption)
                                        .foregroundColor(.dynamicSecondaryText)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.1))
                            )
                        }
                        .padding(.horizontal)
                        
                        // Submit Button
                        Button(action: submitSuggestion) {
                            HStack(spacing: 10) {
                                if suggestionManager.isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                }
                                Text(suggestionManager.isSubmitting ? "Submitting..." : "Submit Suggestion")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: categoryName.isEmpty ? 
                                        [Color.gray, Color.gray.opacity(0.8)] :
                                        [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: categoryName.isEmpty ? Color.clear : Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(categoryName.isEmpty || suggestionManager.isSubmitting)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") { dismiss() })
            .preferredColorScheme(.light)
            .alert("Thank You! 🎉", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your category suggestion has been submitted! We'll review it and may add it in a future update.")
            }
            .alert("Error", isPresented: .constant(suggestionManager.submitError != nil)) {
                Button("OK") {
                    suggestionManager.submitError = nil
                }
            } message: {
                if let error = suggestionManager.submitError {
                    Text(error)
                }
            }
        }
    }
    
    private func submitSuggestion() {
        HapticManager.shared.light()
        
        suggestionManager.submitSuggestion(
            categoryName: categoryName.trimmingCharacters(in: .whitespacesAndNewlines),
            userName: userName.isEmpty ? "Anonymous" : userName.trimmingCharacters(in: .whitespacesAndNewlines)
        ) { result in
            switch result {
            case .success:
                showSuccess = true
                // Clear fields
                categoryName = ""
                userName = ""
            case .failure:
                // Error handled by alert
                break
            }
        }
    }
}

//  Preview
struct SuggestCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        SuggestCategoryView()
    }
}
