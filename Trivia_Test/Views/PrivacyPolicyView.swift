

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
                        
                        Text("Last updated: \(formattedDate)")
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
                        • Device information for analytics
                        • Crash reports and performance data
                        
                        We do not collect personally identifiable information unless explicitly provided by you.
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
                        We use the following third-party services:
                        
                        • Google AdMob for advertising
                        • Analytics services for app improvement
                        • Cloud services for data backup
                        
                        These services have their own privacy policies and data handling practices.
                        """
                    )
                    
                    privacySection(
                        title: "Children's Privacy",
                        content: """
                        We are committed to protecting children's privacy:
                        
                        • We do not knowingly collect personal information from children under 13
                        • Parental consent is required for users under 13
                        • Parents can request deletion of their child's data
                        """
                    )
                    
                    privacySection(
                        title: "Your Rights",
                        content: """
                        You have the right to:
                        
                        • Access your personal data
                        • Request correction of inaccurate data
                        • Request deletion of your data
                        • Opt-out of data collection
                        • Export your data in a portable format
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
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
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

// Terms and Conditions View
struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var acceptedTerms = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms & Conditions")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
                        
                        Text("Last updated: \(formattedDate)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 10)
                    
                    // Agreement notice
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("By using this app, you agree to these Terms & Conditions")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
                    // Content sections
                    termsSection(
                        title: "1. Acceptance of Terms",
                        content: """
                        By downloading, installing, or using the Trivia Game app, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the app.
                        """
                    )
                    
                    termsSection(
                        title: "2. Use License",
                        content: """
                        Permission is granted to temporarily download one copy of the app for personal, non-commercial use only. This is a grant of a license, not a transfer of title, and under this license you may not:
                        
                        • Modify or copy the materials
                        • Use the materials for commercial purposes
                        • Attempt to reverse engineer any software
                        • Remove any copyright or proprietary notations
                        """
                    )
                    
                    termsSection(
                        title: "3. User Accounts",
                        content: """
                        • You are responsible for maintaining the confidentiality of your account
                        • You must provide accurate and complete information
                        • You are responsible for all activities under your account
                        • You must notify us immediately of any unauthorized use
                        • One account per user is permitted
                        """
                    )
                    
                    termsSection(
                        title: "4. Game Rules and Fair Play",
                        content: """
                        Users agree to:
                        
                        • Play fairly and not use cheats, hacks, or exploits
                        • Not manipulate scores or game results
                        • Not share accounts or transfer game items
                        • Respect other players in multiplayer features
                        • Not use automated scripts or bots
                        
                        Violation of these rules may result in account suspension or termination.
                        """
                    )
                    
                    termsSection(
                        title: "5. In-App Purchases",
                        content: """
                        • All purchases are final and non-refundable
                        • Virtual items have no real-world value
                        • We reserve the right to modify prices
                        • Parents are responsible for minor's purchases
                        • Lost items due to account issues may not be restored
                        """
                    )
                    
                    termsSection(
                        title: "6. Intellectual Property",
                        content: """
                        All content in this app, including but not limited to:
                        
                        • Text, graphics, logos, images
                        • Audio, video, and software
                        • Game questions and answers
                        • User interface design
                        
                        Is the property of the app developer and protected by intellectual property laws.
                        """
                    )
                    
                    termsSection(
                        title: "7. Disclaimer",
                        content: """
                        • The app is provided "as is" without warranties
                        • We do not guarantee uninterrupted service
                        • We are not liable for any damages from app use
                        • Quiz content is for entertainment purposes only
                        • We reserve the right to modify or discontinue features
                        """
                    )
                    
                    termsSection(
                        title: "8. Limitation of Liability",
                        content: """
                        In no event shall our company be liable for any:
                        
                        • Direct, indirect, incidental, or consequential damages
                        • Loss of data, profits, or game progress
                        • Damages arising from use or inability to use the app
                        • Damages exceeding the amount paid by the user
                        """
                    )
                    
                    termsSection(
                        title: "9. Privacy",
                        content: """
                        Your use of our app is also governed by our Privacy Policy. Please review our Privacy Policy, which also governs the app and informs users of our data collection practices.
                        """
                    )
                    
                    termsSection(
                        title: "10. Termination",
                        content: """
                        We may terminate or suspend your account and access to the app immediately, without prior notice or liability, for any reason, including breach of these Terms.
                        
                        Upon termination, your right to use the app will cease immediately.
                        """
                    )
                    
                    termsSection(
                        title: "11. Changes to Terms",
                        content: """
                        We reserve the right to modify these terms at any time. We will notify users of any changes by:
                        
                        • Updating the "Last updated" date
                        • Sending in-app notifications
                        • Requiring acceptance for continued use
                        
                        Continued use after changes constitutes acceptance.
                        """
                    )
                    
                    termsSection(
                        title: "12. Contact Information",
                        content: """
                        For questions about these Terms & Conditions, contact us at:
                        
                        Email: ryan.myo.han@gmail.com
                        
                        We aim to respond within 2-3 business days.
                        """
                    )
                    
                    // Acceptance checkbox
                    HStack {
                        Button(action: {
                            acceptedTerms.toggle()
                        }) {
                            Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                .foregroundColor(acceptedTerms ? .green : .gray)
                                .font(.title2)
                        }
                        
                        Text("I have read and accept the Terms & Conditions")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.1))
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
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.2))
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
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
struct LegalViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PrivacyPolicyView()
            TermsAndConditionsView()
        }
    }
}
