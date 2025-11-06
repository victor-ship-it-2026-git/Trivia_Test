
import SwiftUI
internal import Combine

@MainActor
class TransitionCoordinator: ObservableObject {
    @Published var isTransitioning = false
    
    func performTransition(duration: Double = 0.3, _ action: @escaping () -> Void) {
        guard !isTransitioning else { return }
        
        isTransitioning = true
        
        withAnimation(.spring(response: duration, dampingFraction: 0.8)) {
            action()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isTransitioning = false
        }
    }
}
