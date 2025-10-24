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
                    
                    Text("Trivia")
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
                        Text("Categories")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 20)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)
                        
                        // Category Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array([
                                ("All Categories", "general_image", QuizCategory.all),
                                ("Science", "science_image", QuizCategory.science),
                                ("History", "history_image", QuizCategory.history),
                                ("Geography", "geography_image", QuizCategory.geography),
                                ("Pop Culture", "popculture_image", QuizCategory.popCulture),
                                ("Sports", "sports_image", QuizCategory.sports),
                                ("Art & Literature", "art_image", QuizCategory.art),
                                ("Movies", "movies_image", QuizCategory.movies)
                            ].enumerated()), id: \.offset) { index, item in
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
                        .padding(.bottom, 100) // Add padding at bottom so content isn't hidden behind Next button
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
        case "Science": return "flask.fill"
        case "History": return "building.columns.fill"
        case "Geography": return "globe.americas.fill"
        case "Pop Culture": return "tv.fill"
        case "Sports": return "sportscourt.fill"
        case "All Categories": return "book.fill"
        case "Art & Literature": return "paintpalette.fill"
        case "Movies": return "film.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getCategoryGradient(for title: String) -> [Color] {
        switch title {
        case "Science": return [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.1, green: 0.3, blue: 0.5)]
        case "History": return [Color(red: 0.3, green: 0.5, blue: 0.3), Color(red: 0.2, green: 0.4, blue: 0.2)]
        case "Geography": return [Color(red: 0.2, green: 0.5, blue: 0.6), Color(red: 0.1, green: 0.4, blue: 0.5)]
        case "Pop Culture": return [Color(red: 0.9, green: 0.8, blue: 0.7), Color(red: 0.8, green: 0.7, blue: 0.6)]
        case "Sports": return [Color(red: 0.7, green: 0.8, blue: 0.6), Color(red: 0.6, green: 0.7, blue: 0.5)]
        case "All Categories": return [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.2)]
        case "Art & Literature": return [Color(red: 0.9, green: 0.6, blue: 0.7), Color(red: 0.8, green: 0.5, blue: 0.6)]
        case "Movies": return [Color(red: 0.5, green: 0.3, blue: 0.6), Color(red: 0.4, green: 0.2, blue: 0.5)]
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
    @State private var showTermsAndConditions = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var coinsManager = CoinsManager.shared
    
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
                        
                        /* Daily Challenge is not working yet. :D
                        SettingsMenuItem(icon: "calendar.badge.clock", title: "Daily Challenge", color: .purple) {
                            dismiss()
                            showDailyChallengeDetail = true
                        }*/
                        
                        SettingsMenuItem(icon: "bell.badge.fill", title: "Notifications", color: .red) {
                            showNotificationSettings = true
                        }
                        
                        // Code for testing View Reports
                       /* SettingsMenuItem(icon: "exclamationmark.triangle.fill", title: "View Reports", color: .orange) {
                            showAdminReports = true
                        }*/
                        
                        SettingsMenuItem(icon: "lightbulb.fill", title: "Suggest a Category", color: .yellow) {
                            showSuggestCategory = true
                        }
                        
                        // Divider between game features and legal items
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Legal items
                     /*   SettingsMenuItem(icon: "doc.text.fill", title: "Terms & Conditions", color: .indigo) {
                            showTermsAndConditions = true
                        }*/
                        
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
        /*.sheet(isPresented: $showTermsAndConditions) {
            TermsAndConditionsView()
        }*/
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
