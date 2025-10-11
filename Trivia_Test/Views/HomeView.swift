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
    @State private var showAdminReports = false  // ADD THIS LINE
    @State private var showSuggestCategory = false  // ADD THIS


    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.dynamicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {
                        // Back action if needed
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                    .opacity(0) // Hidden but maintains spacing
                    
                    Spacer()
                    
                    Text("Trivia App")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Button(action: {
                        fatalError("Test crash for Crashlytics")
                    }) {
                        Text("🔥 Test Crash (DEBUG ONLY)")
                            .foregroundColor(.red)
                    }
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                  
                }
                .padding()
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : -20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Title
                        Text("Choose a Category")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.dynamicText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Category Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(Array([
                                ("Science", "science_image", QuizCategory.science),
                                ("History", "history_image", QuizCategory.history),
                                ("Geography", "geography_image", QuizCategory.geography),
                                ("Pop Culture", "popculture_image", QuizCategory.popCulture),
                                ("Sports", "sports_image", QuizCategory.sports),
                                ("General", "general_image", QuizCategory.all)
                            ].enumerated()), id: \.offset) { index, item in
                                CategoryCardWithImage(
                                    title: item.0,
                                    imageName: item.1,
                                    isSelected: selectedCategory == item.2,
                                    action: {
                                        // ADD THIS
                                        AnalyticsManager.shared.logCategoryClicked(category: item.2)
                                        
                                        selectedCategory = item.2
                                        gamePresenter.selectedCategory = item.2
                                        
                                        // ADD THIS
                                        AnalyticsManager.shared.logCategorySelected(category: item.2)
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)
                                .offset(y: appearAnimation ? 0 : 30)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.1), value: appearAnimation)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Next Button
                        Button(action: {
                            if selectedCategory != nil {
                                // ADD THIS
                                AnalyticsManager.shared.logScreenView(screenName: "DifficultySelection")
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    appearAnimation = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    startGame()
                                }
                            }
                        }) {
                            Text("Next")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: selectedCategory != nil ?
                                            [Color.blue, Color.purple] :
                                            [Color.gray, Color.gray.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(28)
                                .shadow(color: selectedCategory != nil ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(selectedCategory == nil)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 30)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)
                    }
                }
            }
        }
        .onAppear {
            // ADD THIS
            AnalyticsManager.shared.logScreenView(screenName: "Home")
            
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
                showSuggestCategory: $showSuggestCategory  // ADD THIS

            )
        }
        .sheet(isPresented: $showDailyChallengeDetail) {
            DailyChallengeDetailView()
        }
        .sheet(isPresented: $showAdminReports) {  // ADD THIS
            AdminReportsView()
        }
        .sheet(isPresented: $showSuggestCategory) {  // ADD THIS
                   SuggestCategoryView()
               }
    }
}

// MARK: - Category Card with Image
struct CategoryCardWithImage: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                isPressed = false
            }
        }) {
            VStack(spacing: 0) {
                // Image container
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                    
                    // Check if image exists, otherwise use gradient + icon
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 2 - 30, height: 140)
                            .clipped()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                            )
                    } else {
                        // Fallback: Gradient + Icon
                        LinearGradient(
                            gradient: Gradient(colors: getCategoryGradient(for: title)),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .opacity(isSelected ? 1.0 : 0.7)
                        
                        Image(systemName: getCategoryIcon(for: title))
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 140)
                .cornerRadius(20)
                
                // Title
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .blue : .dynamicText)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        }
    }
    
    private func getCategoryIcon(for title: String) -> String {
        switch title {
        case "Science": return "flask.fill"
        case "History": return "building.columns.fill"
        case "Geography": return "globe.americas.fill"
        case "Pop Culture": return "tv.fill"
        case "Sports": return "sportscourt.fill"
        case "General": return "book.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getCategoryGradient(for title: String) -> [Color] {
        switch title {
        case "Science": return [Color.cyan, Color.blue]
        case "History": return [Color.orange, Color.red]
        case "Geography": return [Color.green, Color.teal]
        case "Pop Culture": return [Color.pink, Color.purple]
        case "Sports": return [Color.yellow, Color.orange]
        case "General": return [Color.indigo, Color.purple]
        default: return [Color.gray, Color.gray.opacity(0.5)]
        }
    }
}

// MARK: - Settings Menu View
struct SettingsMenuView: View {
    let showShop: () -> Void
    let showLeaderboard: () -> Void
    @Binding var showDailyChallengeDetail: Bool
    @Binding var showSuggestCategory: Bool  // ADD THIS

    @State private var showAdminReports = false
    @State private var showNotificationSettings = false  // ADD THIS
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var coinsManager = CoinsManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Coins Display
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        
                        Text("\(coinsManager.coins) Coins")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.dynamicText)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.dynamicCardBackground)
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
                        
                        SettingsMenuItem(icon: "calendar.badge.clock", title: "Daily Challenge", color: .purple) {
                            dismiss()
                            showDailyChallengeDetail = true
                        }
                        
                        // ADD THIS
                        SettingsMenuItem(icon: "bell.badge.fill", title: "Notifications", color: .red) {
                            showNotificationSettings = true
                        }
                        
                        SettingsMenuItem(icon: "exclamationmark.triangle.fill", title: "View Reports", color: .orange) {
                            showAdminReports = true
                        }
                        
                        SettingsMenuItem(icon: "lightbulb.fill", title: "Suggest a Category", color: .yellow) {
                            dismiss()
                            showSuggestCategory = true
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
        .sheet(isPresented: $showNotificationSettings) {  // ADD THIS
            NotificationSettingsView()
        }
        .sheet(isPresented: $showSuggestCategory) {
            SuggestCategoryView()
        }
    }
}


// MARK: - Settings Menu Item
struct SettingsMenuItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.dynamicText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.dynamicCardBackground)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 3)
            )
        }
    }
}







