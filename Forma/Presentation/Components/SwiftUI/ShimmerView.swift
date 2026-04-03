import SwiftUI

struct ShimmerView: View {
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat
    var colors: [Color]

    @State private var shimmerOffset: CGFloat = -200

    init(
        width: CGFloat = 140,
        height: CGFloat = 1.5,
        cornerRadius: CGFloat = AppRadius.card,
        colors: [Color] = [.clear, .white.opacity(0.03), .white.opacity(AppOpacity.shimmer), .white.opacity(0.03), .clear]
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.colors = colors
    }

    var body: some View {
        GeometryReader { _ in
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width)
            .offset(x: shimmerOffset)
        }
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onAppear {
            shimmerOffset = -width
            withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                shimmerOffset = width + 200
            }
        }
    }
}

struct ShimmerModifier: ViewModifier {
    var isActive: Bool
    var width: CGFloat
    var height: CGFloat
    var cornerRadius: CGFloat

    @State private var shimmerOffset: CGFloat = -200

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { _ in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.03), .white.opacity(AppOpacity.shimmer), .white.opacity(0.03), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width)
                    .offset(x: shimmerOffset)
                }
                .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isActive)
            .onChange(of: isActive) { _, active in
                if active {
                    shimmerOffset = -width
                    withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                        shimmerOffset = width + 200
                    }
                }
            }
    }
}

extension View {
    func shimmer(
        isActive: Bool,
        width: CGFloat = 140,
        height: CGFloat = 1.5,
        cornerRadius: CGFloat = AppRadius.card
    ) -> some View {
        modifier(ShimmerModifier(isActive: isActive, width: width, height: height, cornerRadius: cornerRadius))
    }
}
