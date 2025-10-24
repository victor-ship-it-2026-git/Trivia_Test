import SwiftUI

// Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        
                        Text("Last updated: October 25, 2025")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    // Content sections
                    privacySection(
                        title: "Information We Collect",
                        content: """
                        We collect information to provide better services to our users. This includes:
                        
                        • Game progress and scores
                        • User preferences and settings
                        • Device information (device type, operating system version, unique device identifiers)
                        • Usage data and analytics (gameplay statistics, session duration, features used)
                        • Crash reports and performance data
                        • IP address and approximate location (for analytics purposes)
                        • Advertising identifiers (IDFA on iOS) for personalized ads
                        
                        We do not collect personally identifiable information such as your name, email address, or phone number unless explicitly provided by you for support purposes.
                        """
                    )
                    
                    privacySection(
                        title: "How We Use Information",
                        content: """
                        The information we collect is used to:
                        
                        • Improve game experience and performance
                        • Save your progress and achievements
                        • Provide personalized game recommendations
                        • Fix bugs and improve app stability
                        • Analyze usage patterns to enhance features
                        """
                    )
                    
                    privacySection(
                        title: "Data Storage and Security",
                        content: """
                        Your data is stored securely using industry-standard encryption methods:
                        
                        • Local data is stored on your device
                        • Cloud sync data is encrypted in transit and at rest
                        • We implement regular security audits
                        • Access to data is strictly controlled
                        """
                    )
                    
                    privacySection(
                        title: "Third-Party Services",
                        content: """
                        We use the following third-party services that may collect and process your information:
                        
                        • Google AdSense/AdMob: For displaying advertisements. Google may use cookies and advertising identifiers to show personalized ads based on your interests.
                        
                        • Google Analytics: For analyzing app usage, user behavior, and improving our services. Google Analytics collects anonymous usage statistics.
                        
                        • Firebase: For app analytics, crash reporting, and performance monitoring. Firebase is a Google service that helps us understand how users interact with our app.
                        
                        • Cloud Storage Services: For secure data backup and synchronization across devices.
                        
                        These services have their own privacy policies and data handling practices. We encourage you to review their policies at:
                        • Google Privacy Policy: https://policies.google.com/privacy
                        • Firebase Privacy Policy: https://firebase.google.com/support/privacy
                        """
                    )
                    
                    privacySection(
                        title: "Children's Privacy",
                        content: """
                        Our app is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13 years of age.
                        
                        If you are a parent or guardian and believe that your child under 13 has provided us with personal information, please contact us immediately at ryan.myo.han@gmail.com, and we will take steps to delete such information from our systems.
                        
                        In compliance with the Children's Online Privacy Protection Act (COPPA), we:
                        
                        • Do not require children to provide more information than necessary to use the app
                        • Do not knowingly collect, use, or disclose personal information from children under 13
                        • Will delete any information we discover was collected from a child under 13
                        """
                    )
                    
                    privacySection(
                        title: "Your Rights",
                        content: """
                        You have the right to:
                        
                        • Access your personal data that we have collected
                        • Request correction of inaccurate data
                        • Request deletion of your data
                        • Opt-out of data collection and personalized advertising
                        
                        To exercise these rights, please contact us at ryan.myo.han@gmail.com.
                        """
                    )
                    
                    privacySection(
                        title: "California Privacy Rights (CCPA/CPRA)",
                        content: """
                        If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA) and California Privacy Rights Act (CPRA):
                        
                        Right to Know: You have the right to request information about the categories and specific pieces of personal information we have collected about you.
                        
                        Right to Delete: You have the right to request deletion of your personal information, subject to certain exceptions.
                        
                        Right to Opt-Out: You have the right to opt-out of the sale or sharing of your personal information. While we do not "sell" your personal information in the traditional sense, we do share information with advertising partners which may be considered a "sale" under CCPA. You can opt-out by:
                        • Disabling personalized ads in your device settings (iOS: Settings > Privacy > Tracking)
                        • Contacting us at ryan.myo.han@gmail.com
                        
                        Right to Non-Discrimination: We will not discriminate against you for exercising any of your CCPA/CPRA rights.
                        
                        Categories of Personal Information We Collect:
                        • Identifiers (device ID, advertising ID, IP address)
                        • Internet or network activity (usage data, interactions with ads)
                        • Geolocation data (approximate location based on IP address)
                        • Inferences (preferences, behavior patterns)
                        
                        How to Exercise Your Rights: To submit a request, please email us at ryan.myo.han@gmail.com with the subject line "California Privacy Rights Request." We will respond to your request within 45 days.
                        """
                    )
                    
                    privacySection(
                        title: "California Online Privacy Protection Act (CalOPPA) Compliance",
                        content: """
                        In compliance with CalOPPA, we agree to the following:
                        
                        Do Not Track Signals: Our app does not currently respond to "Do Not Track" (DNT) signals. However, you can opt-out of personalized advertising through your device settings.
                        
                        Third-Party Behavioral Tracking: We allow third-party companies (Google AdSense/AdMob, Google Analytics, Firebase) to collect information about your online activities over time and across different websites and apps when you use our service.
                        
                        Changes to Privacy Policy: Users will be notified of any privacy policy changes on this page. The "Last Updated" date at the top of this policy will be revised when changes are made.
                        
                        How to Opt-Out of Interest-Based Advertising:
                        • iOS Users: Go to Settings > Privacy > Tracking, and disable "Allow Apps to Request to Track"
                        • You can also reset your advertising identifier in Settings > Privacy > Apple Advertising
                        """
                    )
                    
                    privacySection(
                        title: "Contact Us",
                        content: """
                        If you have questions about this Privacy Policy, please contact us:
                        
                        Email: ryan.myo.han@gmail.com
                        
                        We will respond to your inquiry within 48 hours.
                        """
                    )
                }
                .padding()
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.96))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(content)
                .font(.body)
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

// Preview
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
