<<<<<<< HEAD
=======
<<<<<<< HEAD

=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
import SwiftUI

struct HomeView: View {
    let startGame: () -> Void
    let showLeaderboard: () -> Void
    @StateObject private var coinsManager = CoinsManager.shared
    @StateObject private var challengeManager = DailyChallengeManager.shared
    @StateObject private var lifelineManager = LifelineManager.shared
<<<<<<< HEAD
    @StateObject private var gamePresenter = GamePresenter()
    @State private var showShop = false
    @State private var showDailyChallengeDetail = false
    @State private var showSettings = false
    @State private var selectedCategory: QuizCategory? = nil
    @State private var appearAnimation = false  // NEW: Add this
=======
<<<<<<< HEAD
    @State private var showShop = false
    @State private var showDailyChallengeDetail = false
=======
    @StateObject private var gamePresenter = GamePresenter()
    @State private var showShop = false
    @State private var showDailyChallengeDetail = false
    @State private var showSettings = false
    @State private var selectedCategory: QuizCategory? = nil
    @State private var appearAnimation = false  // NEW: Add this
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
<<<<<<< HEAD
            Color.dynamicBackground
                .ignoresSafeArea()
=======
<<<<<<< HEAD
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
>>>>>>> d8765c0 (Resolve merge)
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                    
                    Spacer()
                    
                    Text("Trivia App")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                }
                .padding()
                .opacity(appearAnimation ? 1 : 0)  // NEW
                .offset(y: appearAnimation ? 0 : -20)  // NEW
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Title
                        Text("Choose a Category")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.dynamicText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .opacity(appearAnimation ? 1 : 0)  // NEW
                            .offset(y: appearAnimation ? 0 : 20)  // NEW
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)  // NEW
                        
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
                                        selectedCategory = item.2
                                        gamePresenter.selectedCategory = item.2
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)  // NEW
                                .offset(y: appearAnimation ? 0 : 30)  // NEW
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.1), value: appearAnimation)  // NEW
                            }
                        }
                        .padding(.horizontal)
                        
                        // Next Button
                        Button(action: {
                            if selectedCategory != nil {
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
                        .opacity(appearAnimation ? 1 : 0)  // NEW
                        .offset(y: appearAnimation ? 0 : 30)  // NEW
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)  // NEW
                    }
                }
            }
        }
<<<<<<< HEAD
=======
=======
            Color.dynamicBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation Bar
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                    
                    Spacer()
                    
                    Text("Trivia App")
                        .font(.headline)
                        .foregroundColor(.dynamicText)
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.dynamicText)
                    }
                }
                .padding()
                .opacity(appearAnimation ? 1 : 0)  // NEW
                .offset(y: appearAnimation ? 0 : -20)  // NEW
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 25) {
                        // Title
                        Text("Choose a Category")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.dynamicText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .opacity(appearAnimation ? 1 : 0)  // NEW
                            .offset(y: appearAnimation ? 0 : 20)  // NEW
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appearAnimation)  // NEW
                        
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
                                        selectedCategory = item.2
                                        gamePresenter.selectedCategory = item.2
                                    }
                                )
                                .opacity(appearAnimation ? 1 : 0)  // NEW
                                .offset(y: appearAnimation ? 0 : 30)  // NEW
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2 + Double(index) * 0.1), value: appearAnimation)  // NEW
                            }
                        }
                        .padding(.horizontal)
                        
                        // Next Button
                        Button(action: {
                            if selectedCategory != nil {
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
                        .opacity(appearAnimation ? 1 : 0)  // NEW
                        .offset(y: appearAnimation ? 0 : 30)  // NEW
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: appearAnimation)  // NEW
                    }
                }
            }
        }
>>>>>>> d8765c0 (Resolve merge)
        .onAppear {  // NEW
            withAnimation {
                appearAnimation = true
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsMenuView(
                showShop: $showShop,
                showLeaderboard: { showLeaderboard() },
                showDailyChallengeDetail: $showDailyChallengeDetail
            )
        }
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
        .sheet(isPresented: $showShop) {
            ShopView()
        }
        .sheet(isPresented: $showDailyChallengeDetail) {
            DailyChallengeDetailView()
        }
    }
}
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
>>>>>>> d8765c0 (Resolve merge)
// Updated Category Card with Image and Selection State
struct CategoryCardWithImage: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
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
            VStack(spacing: 0) {
                // Image container
                ZStack {
                    // Background for when image loads
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                    
                    // Actual Image
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)  // IMPORTANT: Fill the space
                        .frame(width: UIScreen.main.bounds.width / 2 - 30, height: 140)  // Set exact width & height
                        .clipped()  // Clip overflow
                        .cornerRadius(20)
                        .overlay(
                            // Darker overlay when selected
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                        )
                }
                .frame(height: 140)
                
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
            .scaleEffect(isPressed ? 0.95 : 1.0)
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
}

// Settings Menu View (unchanged from before)
struct SettingsMenuView: View {
    @Binding var showShop: Bool
    let showLeaderboard: () -> Void
    @Binding var showDailyChallengeDetail: Bool
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
                            showShop = true
                        }
                        
                        SettingsMenuItem(icon: "trophy.fill", title: "Leaderboard", color: .blue) {
                            dismiss()
                            showLeaderboard()
                        }
                        
                        SettingsMenuItem(icon: "calendar.badge.clock", title: "Daily Challenge", color: .purple) {
                            dismiss()
                            showDailyChallengeDetail = true
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
    }
}

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
<<<<<<< HEAD
=======
>>>>>>> f38f48a (Initial commit - Trivia app)
>>>>>>> d8765c0 (Resolve merge)
