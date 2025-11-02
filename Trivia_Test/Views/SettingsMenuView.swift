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