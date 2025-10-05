import SwiftUI

struct NameInputView: View {
    @Binding var playerName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.dynamicBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Enter Your Name")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.dynamicText)
                        .padding(.top, 40)
                    
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button(action: onSave) {
                        Text("Save Score")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            }
            .foregroundColor(.blue))
        }
    }
}
