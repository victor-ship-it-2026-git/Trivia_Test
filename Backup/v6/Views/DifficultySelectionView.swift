import SwiftUI

struct DifficultySelectionView: View {
    let goBack: () -> Void
    let startGame: () -> Void
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
                                 
                                 VStack(spacing: 30) {
                                     HStack {
                                         Button(action: goBack) {
                                             HStack(spacing: 5) {
                                                 Image(systemName: "arrow.left")
                                                 Text("Back")
                                             }
                                             .font(.headline)
                                             .foregroundColor(.blue)
                                         }
                                         Spacer()
                                     }
                                     .padding()
                                     
                                     Spacer()
                                     
                                     VStack(spacing: 10) {
                                         Text("Choose Difficulty")
                                             .font(.system(size: 34, weight: .bold))
                                             .foregroundColor(.dynamicText)
                                         
                                         Text("Step 2 of 2")
                                             .font(.subheadline)
                                             .foregroundColor(.dynamicSecondaryText)
                                     }
                                     
                                     HStack(spacing: 10) {
                                         Text("Category:")
                                             .font(.subheadline)
                                             .foregroundColor(.dynamicSecondaryText)
                                         
                                         HStack(spacing: 8) {
                                             Text(presenter.selectedCategory.emoji)
                                             Text(presenter.selectedCategory.rawValue)
                                                 .font(.subheadline)
                                                 .fontWeight(.semibold)
                                                 .foregroundColor(.dynamicText)
                                         }
                                         .padding(.horizontal, 16)
                                         .padding(.vertical, 8)
                                         .background(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                                         .cornerRadius(20)
                                     }
                                     
                                     Spacer()
                                     
                                     VStack(spacing: 25) {
                                         ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                             DifficultyCard(
                                                 difficulty: difficulty,
                                                 isSelected: presenter.selectedDifficulty == difficulty,
                                                 action: { presenter.selectedDifficulty = difficulty }
                                             )
                                         }
                                     }
                                     .padding(.horizontal, 30)
                                     
                                     Spacer()
                                     
                                     Text("Available Questions: \(presenter.getFilteredQuestions().count)")
                                         .font(.subheadline)
                                         .foregroundColor(.dynamicSecondaryText)
                                         .padding(.horizontal, 30)
                                     
                                     Button(action: startGame) {
                                         HStack {
                                             Image(systemName: "play.fill")
                                             Text("Start Game")
                                         }
                                         .font(.title3)
                                         .fontWeight(.semibold)
                                         .foregroundColor(.white)
                                         .frame(maxWidth: .infinity)
                                         .frame(height: 60)
                                         .background(presenter.getFilteredQuestions().isEmpty ? Color.gray : Color.green)
                                         .cornerRadius(30)
                                     }
                                     .disabled(presenter.getFilteredQuestions().isEmpty)
                                     .padding(.horizontal, 30)
                                     .padding(.bottom, 40)
                                 }
                             }
                         }
                     }
