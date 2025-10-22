import SwiftUI

struct ParticleEffect: View {
    let type: ParticleType
    @State private var particles: [Particle] = []
    
    enum ParticleType {
        case star, sparkle, heart
        
        var systemImage: String {
            switch self {
            case .star: return "star.fill"
            case .sparkle: return "sparkle"
            case .heart: return "heart.fill"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Image(systemName: type.systemImage)
                        .foregroundColor(particle.color)
                        .font(.system(size: particle.size))
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
    }
    
    private func generateParticles(in size: CGSize) {
        let colors: [Color] = [.yellow, .orange, .pink, .purple, .blue, .cyan]
        
        for i in 0..<30 {
            let particle = Particle(
                id: UUID(),
                x: CGFloat.random(in: -50...size.width + 50),
                y: size.height + 50,
                size: CGFloat.random(in: 12...24),
                color: colors.randomElement() ?? .yellow,
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: Double.random(in: 1.5...3.0)).delay(Double(i) * 0.03)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].y = -100
                    particles[index].rotation += 360
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct Particle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var rotation: Double
    var opacity: Double
}
