import SwiftUI

struct ShimmerText: View {
    let text: String
    @State private var opacity: Double = 0.3

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .medium))
            .tracking(2.6)
            .foregroundColor(.white.opacity(opacity))
            .padding(.bottom, 50)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 0.6
                }
            }
    }
}

func tapHint(_ text: String) -> some View {
    VStack {
        Spacer()
        ShimmerText(text: text)
    }
}
