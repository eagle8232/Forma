import SwiftUI

struct KineticParticle {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var radius: Double
    var alpha: Double
    var life: Double
}

struct KineticCard: View {
    let isActive: Bool

    private let words = ["Every", "day", "you", "choose", "·", "who", "you", "become."]
    private let accentIndex = 4

    @State private var visibleCount: Int = 0
    @State private var particles: [KineticParticle] = []
    @State private var renderParticles: [KineticParticle] = []
    @State private var particlesActive: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            FlowLayout(spacing: CGSize(width: 12, height: 8)) {
                ForEach(words.indices, id: \.self) { i in
                    Text(words[i])
                        .font(.system(
                            size: 38,
                            weight: i == accentIndex ? .light : .bold
                        ))
                        .foregroundColor(
                            i == accentIndex
                                ? .white.opacity(0.30)
                                : .white
                        )
                        .tracking(-1)
                        .opacity(i < visibleCount ? 1 : 0)
                        .scaleEffect(i < visibleCount ? 1.0 : 0.88)
                        .offset(y: i < visibleCount ? 0 : 12)
                        .animation(
                            .spring(response: 0.2, dampingFraction: 0.75),
                            value: visibleCount
                        )
                }
            }
            .padding(.horizontal, 44)

            TimelineView(.animation(minimumInterval: 1/60, paused: !particlesActive)) { _ in
                Canvas { ctx, size in
                    var updatedParticles: [KineticParticle] = []
                    for p in renderParticles {
                        var particle = p
                        particle.x += particle.vx
                        particle.y += particle.vy
                        particle.vy += 0.04
                        particle.life -= 0.02
                        particle.alpha = particle.life * 0.65
                        if particle.life > 0 {
                            ctx.opacity = particle.alpha
                            ctx.fill(
                                Path(ellipseIn: CGRect(
                                    x: particle.x - particle.radius,
                                    y: particle.y - particle.radius,
                                    width: particle.radius * 2,
                                    height: particle.radius * 2
                                )),
                                with: .color(.white)
                            )
                            updatedParticles.append(particle)
                        }
                    }
                    DispatchQueue.main.async {
                        renderParticles = updatedParticles
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .opacity(particlesActive ? 1 : 0)

            tapHint("Tap to continue")
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            if active {
                DispatchQueue.main.async {
                    visibleCount = 0
                    animateWords()
                }
            }
        }
    }

    private func animateWords() {
        for i in words.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.155) {
                visibleCount = i + 1
                if i == words.count - 1 {
                    spawnParticles()
                }
            }
        }
    }

    private func spawnParticles() {
        particlesActive = true
        particles = (0..<32).map { _ in
            let angle = Double.random(in: 0..<(.pi * 2))
            let speed = Double.random(in: 1.8...5.0)
            return KineticParticle(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                vx: cos(angle) * speed,
                vy: sin(angle) * speed,
                radius: Double.random(in: 1.5...4.0),
                alpha: Double.random(in: 0.5...0.9),
                life: 1.0
            )
        }
        renderParticles = particles
    }
}

struct FlowLayout: Layout {
    var spacing: CGSize

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGSize) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing.height
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing.width
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + lineHeight
        }
    }
}

#Preview {
    KineticCard(isActive: true)
        .preferredColorScheme(.dark)
}
