
import SwiftUI

struct CategorySelectionView: View {
    let goHome: () -> Void
    let goNext: () -> Void
    @ObservedObject var presenter: GamePresenter
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ?
                    [Color.blue.opacity(0.2), Color.purple.opacity(0.2)] :
                    [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button(action: goHome) {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.left")
                            Text("Home")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                
                VStack(spacing: 10) {
                    Text("Choose Your Category")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.dynamicText)
                    
                    Text("Step 1 of 2")
                        .font(.subheadline)
                        .foregroundColor(.dynamicSecondaryText)
                }
                .padding(.top, 10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(QuizCategory.allCases, id: \.self) { category in
                            CategoryCard(
                                category: category,
                                isSelected: presenter.selectedCategory == category,
                                action: { presenter.selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                VStack(spacing: 15) {
                    Text("Selected: \(presenter.selectedCategory.emoji) \(presenter.selectedCategory.rawValue)")
                        .font(.headline)
                        .foregroundColor(.dynamicSecondaryText)
                    
                    Button(action: goNext) {
                        HStack {
                            Text("Next: Choose Difficulty")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .cornerRadius(28)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            colorScheme == .dark ?
                                Color(red: 0.1, green: 0.1, blue: 0.12).opacity(0.98) :
                                Color.white.opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}
