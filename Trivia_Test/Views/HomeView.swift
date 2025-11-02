import SwiftUI

struct HomeView: View {
    let startGame: () -> Void
    let showLeaderboard: () -> Void
    let showShop: () -> Void
    @ObservedObject var gamePresenter: GamePresenter
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var challengeManager = DailyChallengeManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
    @State private var showDailyChallengeDetail = false
    @State private var showSettings = false
    @State private var selectedCategory: QuizCategory? = nil
    @State private var appearAnimation = false
    @State private var showAdminReports = false
    @State private var showSuggestCategory = false
    @State private var categoryOrder: [(String, String, QuizCategory)] = []
    @AppStorage("hasShuffledCategories") private var hasShuffledCategories = false

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Spacer()
                        .frame(width: 44)
                    
                    Spacer()
                    
                    Text("Trivia Quest")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : -20)
                
                // Enhanced ScrollView with smooth scrolling
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Title
                        Text("Categories to choose from")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Category Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(categoryOrder.enumerated()), id: \.offset) { index, item in
                                CategoryCardModern(
                                    title: item.0,
                                    imageName: item.1,
                                    isSelected: selectedCategory == item.2,
                                    action: {
                                        AnalyticsManager.shared.logCategoryClicked(category: item.2)
                                        
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedCategory = item.2
                                        }
                                        gamePresenter.selectedCategory = item.2
                                        
                                        AnalyticsManager.shared.logCategorySelected(category: item.2)
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.08), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
                .scrollBounceBehavior(.basedOnSize) // Smooth bounce behavior
                .scrollClipDisabled(false) // Better clipping for smooth appearance
                
                // Next Button (Fixed at bottom)
                VStack {
                    Button(action: {
                        if selectedCategory != nil {
                            AnalyticsManager.shared.logScreenView(screenName: "DifficultySelection")
                            
                            HapticManager.shared.selection()
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                appearAnimation = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                startGame()
                            }
                        }
                    }) {
                        Text("Next")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(selectedCategory != nil ? .white : Color.gray.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedCategory != nil ?
                                    Color.orange :
                                    Color.gray.opacity(0.3)
                            )
                            .cornerRadius(16)
                    }
                    .disabled(selectedCategory == nil)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 30)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: appearAnimation)
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            }
        }
        .onAppear {
            AnalyticsManager.shared.logScreenView(screenName: "Home")
            
            // Initialize category order
            if categoryOrder.isEmpty {
                setupCategoryOrder()
            }
            
            selectedCategory = gamePresenter.selectedCategory
            withAnimation {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsMenuView(
                showShop: showShop,
                showLeaderboard: showLeaderboard,
                showDailyChallengeDetail: $showDailyChallengeDetail,
                showSuggestCategory: $showSuggestCategory
            )
        }
        .sheet(isPresented: $showDailyChallengeDetail) {
            DailyChallengeDetailView()
        }
        .sheet(isPresented: $showAdminReports) {
            AdminReportsView()
        }
        .sheet(isPresented: $showSuggestCategory) {
            SuggestCategoryView()
        }
    }
    
    // Setup category order - randomize on first launch
    private func setupCategoryOrder() {
        let allCategory = ("All Categories", "general_image", QuizCategory.all)
        
        var otherCategories = [
            ("Geography", "geography_image", QuizCategory.geography),
            ("Science", "science_image", QuizCategory.science),
            ("History", "history_image", QuizCategory.history),
            ("Movies", "movies_image", QuizCategory.movies),
            ("Math", "math_image", QuizCategory.math),
            ("Music", "music_image", QuizCategory.music),
            ("Sports", "sports_image", QuizCategory.sports),
            ("Pop Culture", "popculture_image", QuizCategory.popCulture),
            ("Celebrities", "celebrities_image", QuizCategory.celebrities),
            ("The 90s", "90s_image", QuizCategory.the90s),
            ("2000s Era", "2000s_image", QuizCategory.the2000s),
            ("Gen Z", "genz_image", QuizCategory.genZ)
        ]
        
        // Only shuffle on first launch
        if !hasShuffledCategories {
            otherCategories.shuffle()
            hasShuffledCategories = true
            print("🎲 Categories shuffled for first time!")
        }
        
        // Always put "All Categories" first
        categoryOrder = [allCategory] + otherCategories
    }
}

// Modern Category Card with smooth interactions
struct CategoryCardModern: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            action()
        }) {
            VStack(spacing: 0) {
                // Image container
                ZStack(alignment: .topTrailing) {
                    // Image or gradient background
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                    } else {
                        // Fallback gradient
                        LinearGradient(
                            gradient: Gradient(colors: getCategoryGradient(for: title)),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 140)
                        
                        Image(systemName: getCategoryIcon(for: title))
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    // Checkmark badge
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(8)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(height: 140)
                .cornerRadius(16)
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.orange : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    private func getCategoryIcon(for title: String) -> String {
        switch title {
        case "Geography": return "globe.americas.fill"
        case "Science": return "flask.fill"
        case "History": return "building.columns.fill"
        case "Movies": return "film.fill"
        case "Math": return "function"
        case "Music": return "music.note"
        case "Sports": return "sportscourt.fill"
        case "Pop Culture": return "tv.fill"
        case "Celebrities": return "star.fill"
        case "The 90s": return "vhs.fill"
        case "2000s Era": return "iphone.gen1"
        case "Gen Z": return "flame.fill"
        case "All Categories": return "square.grid.2x2.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getCategoryGradient(for title: String) -> [Color] {
        switch title {
        case "Geography": return [Color(red: 0.2, green: 0.5, blue: 0.6), Color(red: 0.1, green: 0.4, blue: 0.5)]
        case "Science": return [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.1, green: 0.3, blue: 0.5)]
        case "History": return [Color(red: 0.3, green: 0.5, blue: 0.3), Color(red: 0.2, green: 0.4, blue: 0.2)]
        case "Movies": return [Color(red: 0.5, green: 0.3, blue: 0.6), Color(red: 0.4, green: 0.2, blue: 0.5)]
        case "Math": return [Color(red: 0.1, green: 0.3, blue: 0.7), Color(red: 0.0, green: 0.2, blue: 0.6)]
        case "Music": return [Color(red: 0.8, green: 0.2, blue: 0.5), Color(red: 0.7, green: 0.1, blue: 0.4)]
        case "Sports": return [Color(red: 0.7, green: 0.8, blue: 0.6), Color(red: 0.6, green: 0.7, blue: 0.5)]
        case "Pop Culture": return [Color(red: 0.9, green: 0.8, blue: 0.7), Color(red: 0.8, green: 0.7, blue: 0.6)]
        case "Celebrities": return [Color(red: 0.9, green: 0.6, blue: 0.2), Color(red: 0.8, green: 0.5, blue: 0.1)]
        case "The 90s": return [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 0.5, green: 0.2, blue: 0.7)]
        case "2000s Era": return [Color(red: 0.2, green: 0.7, blue: 0.9), Color(red: 0.1, green: 0.6, blue: 0.8)]
        case "Gen Z": return [Color(red: 0.9, green: 0.3, blue: 0.3), Color(red: 0.8, green: 0.2, blue: 0.2)]
        case "All Categories": return [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.2)]
        default: return [Color.gray, Color.gray.opacity(0.7)]
        }
    }
}
