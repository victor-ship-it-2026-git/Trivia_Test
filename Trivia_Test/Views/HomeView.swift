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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Title
                        Text("Categories to choose from")
                            .font(.system(size: 24, weight: .bold))
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

// Modern Category Card
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

// Settings Menu View
struct SettingsMenuView: View {
    let showShop: () -> Void
    let showLeaderboard: () -> Void
    @Binding var showDailyChallengeDetail: Bool
    @Binding var showSuggestCategory: Bool
    @State private var showAdminReports = false
    @State private var showNotificationSettings = false
    @State private var showPrivacyPolicy = false
    @State private var showDeleteDataConfirmation = false
    @State private var isDeletingData = false
    @State private var deleteSuccess = false
    @State private var deleteError: String?
    @State private var showQuestionsDiagnostic = false  // ADD THIS LINE
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var firebaseManager = FirebaseLeaderboardManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Coins Display
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("\(coinsManager.coins) Coins")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                    )
                    .padding(.horizontal)
                    
                    // Menu Options
                    VStack(spacing: 15) {
                        SettingsMenuItem(icon: "cart.fill", title: "Shop", color: .orange) {
                            dismiss()
                            showShop()
                        }
                        
                        SettingsMenuItem(icon: "trophy.fill", title: "Leaderboard", color: .blue) {
                            dismiss()
                            showLeaderboard()
                        }
                        
                        SettingsMenuItem(icon: "bell.badge.fill", title: "Notifications", color: .red) {
                            showNotificationSettings = true
                        }
                        
                        // Debug Questions Button
                       /* SettingsMenuItem(icon: "wrench.fill", title: "Debug Questions", color: .purple) {
                            showQuestionsDiagnostic = true
                        }*/
                        
                        SettingsMenuItem(icon: "lightbulb.fill", title: "Suggest a Category", color: .yellow) {
                            showSuggestCategory = true
                        }
                        
                      
                        // Divider between game features and data/legal items
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Delete Personal Data - THE CTA IS HERE!
                        SettingsMenuItem(icon: "trash.fill", title: "Delete Personal Data", color: .red) {
                            showDeleteDataConfirmation = true
                        }
                        
                        SettingsMenuItem(icon: "hand.raised.fill", title: "Privacy Policy", color: .green) {
                            showPrivacyPolicy = true
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
        .sheet(isPresented: $showAdminReports) {
            AdminReportsView()
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showSuggestCategory) {
            SuggestCategoryView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
       /* .sheet(isPresented: $showQuestionsDiagnostic) {
            QuestionsDiagnosticView()
        }*/
        .confirmationDialog("Delete Personal Data", isPresented: $showDeleteDataConfirmation, titleVisibility: .visible) {
            Button("Delete My Data", role: .destructive) {
                deletePersonalData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your name from the global leaderboard. This action cannot be undone.")
        }
        .alert("Data Deleted", isPresented: $deleteSuccess) {
            Button("OK") {
                deleteSuccess = false
            }
        } message: {
            Text("Your personal data has been successfully deleted from the leaderboard.")
        }
        .alert("Error", isPresented: .constant(deleteError != nil)) {
            Button("OK") {
                deleteError = nil
            }
        } message: {
            if let error = deleteError {
                Text(error)
            }
        }
        .overlay {
            if isDeletingData {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Deleting data...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
                    )
                }
            }
        }
    }
    
    private func deletePersonalData() {
        // Get the saved player name
        guard let playerName = UserDefaults.standard.string(forKey: "LastSavedPlayerName"),
              !playerName.isEmpty else {
            deleteError = "No personal data found to delete."
            return
        }
        
        isDeletingData = true
        
        firebaseManager.deleteUserEntries(playerName: playerName) { result in
            DispatchQueue.main.async {
                isDeletingData = false
                
                switch result {
                case .success(let count):
                    if count > 0 {
                        // Clear the saved player name from UserDefaults
                        UserDefaults.standard.removeObject(forKey: "LastSavedPlayerName")
                        
                        deleteSuccess = true
                        print("✅ Successfully deleted \(count) entries for \(playerName)")
                    } else {
                        deleteError = "No leaderboard entries found for your name."
                    }
                    
                case .failure(let error):
                    deleteError = "Failed to delete data: \(error.localizedDescription)"
                    print("❌ Error deleting entries: \(error.localizedDescription)")
                }
            }
        }
    }
}

// Settings Menu Item
struct SettingsMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
        }
    }
}
