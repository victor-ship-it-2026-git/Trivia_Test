import SwiftUI

struct BonusPointsAnimation: View {
    let points: Int
    let multiplier: Int
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        if points > 10 {
            VStack(spacing: 2) {
                Text("+\(points)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                
                if multiplier > 1 {
                    Text("×\(multiplier) Streak!")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = -50
                    opacity = 0
                }
            }
        }
    }
}
