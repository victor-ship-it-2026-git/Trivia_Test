import SwiftUI

struct DifficultySelectionView: View {
    let goBack: () -> Void
    let startGame: () -> Void
    @ObservedObject var presenter: GamePresenter
    @Environment(\.colorScheme) var colorScheme
<<<<<<< HEAD
    @State private var appearAnimation = false
=======
<<<<<<< HEAD
>>>>>>> d8765c0 (Resolve merge)
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            appearAnimation = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            goBack()
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Trivia App")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .opacity(0)
                }
                .padding()
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : -20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Choose Difficulty")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.dynamicText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Step 2 of 2")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Selected Category Display
                        HStack(spacing: 12) {
                            Text("Category:")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                            
                            HStack(spacing: 8) {
                                Text(presenter.selectedCategory.emoji)
                                    .font(.title3)
                                Text(presenter.selectedCategory.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.dynamicText)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                            )
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(x: appearAnimation ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
                        
                        // Difficulty Cards
                        VStack(spacing: 16) {
                            ForEach(Array(Difficulty.allCases.enumerated()), id: \.element) { index, difficulty in
                                DifficultyCardModern(
                                    difficulty: difficulty,
                                    isSelected: presenter.selectedDifficulty == difficulty,
                                    action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            presenter.selectedDifficulty = difficulty
                                        }
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.1), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Available Questions Info
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Available Questions: \(presenter.getFilteredQuestions().count)")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                        }
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appearAnimation)
                        
                        // Start Game Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                startGame()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: presenter.getFilteredQuestions().isEmpty ?
                                        [Color.gray, Color.gray.opacity(0.8)] :
                                        [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: presenter.getFilteredQuestions().isEmpty ? Color.clear : Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(presenter.getFilteredQuestions().isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                appearAnimation = true
            }
        }
    }
}

// Modern Difficulty Card
struct DifficultyCardModern: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
<<<<<<< HEAD
=======
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
=======
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            appearAnimation = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            goBack()
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Trivia App")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .opacity(0)
                }
                .padding()
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : -20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Choose Difficulty")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.dynamicText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Step 2 of 2")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Selected Category Display
                        HStack(spacing: 12) {
                            Text("Category:")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                            
                            HStack(spacing: 8) {
                                Text(presenter.selectedCategory.emoji)
                                    .font(.title3)
                                Text(presenter.selectedCategory.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.dynamicText)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(colorScheme == .dark ? 0.25 : 0.15))
                            )
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(x: appearAnimation ? 0 : -20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appearAnimation)
                        
                        // Difficulty Cards
                        VStack(spacing: 16) {
                            ForEach(Array(Difficulty.allCases.enumerated()), id: \.element) { index, difficulty in
                                DifficultyCardModern(
                                    difficulty: difficulty,
                                    isSelected: presenter.selectedDifficulty == difficulty,
                                    action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            presenter.selectedDifficulty = difficulty
                                        }
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3 + Double(index) * 0.1), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Available Questions Info
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Available Questions: \(presenter.getFilteredQuestions().count)")
                                .font(.subheadline)
                                .foregroundColor(.dynamicSecondaryText)
                        }
                        .padding(.horizontal)
                        .opacity(appearAnimation ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: appearAnimation)
                        
                        // Start Game Button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                startGame()
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                Text("Start Game")
                            }
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: presenter.getFilteredQuestions().isEmpty ?
                                        [Color.gray, Color.gray.opacity(0.8)] :
                                        [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                            .shadow(color: presenter.getFilteredQuestions().isEmpty ? Color.clear : Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(presenter.getFilteredQuestions().isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                appearAnimation = true
            }
        }
    }
}

// Modern Difficulty Card
struct DifficultyCardModern: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
>>>>>>> d8765c0 (Resolve merge)
    var difficultyIcon: String {
        switch difficulty {
        case .easy: return "🌱"
        case .medium: return "⚡️"
        case .hard: return "🔥"
        }
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                isPressed = false
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(difficulty.color.opacity(colorScheme == .dark ? 0.3 : 0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(difficultyIcon)
                        .font(.system(size: 30))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.dynamicText)
                    
                    Text(difficulty.description)
                        .font(.subheadline)
                        .foregroundColor(.dynamicSecondaryText)
                }
                
                Spacer()
                
                // Checkmark
                ZStack {
                    Circle()
                        .stroke(isSelected ? difficulty.color : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isSelected {
                        Circle()
                            .fill(difficulty.color)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? difficulty.color.opacity(colorScheme == .dark ? 0.15 : 0.1) : Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: isSelected ? 8 : 5, x: 0, y: isSelected ? 4 : 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? difficulty.color : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
    }
}
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
