import SwiftUI

struct EnoughCard: View {
    let isActive: Bool

    @State private var wordScale: CGFloat = 0.84
    @State private var wordOpacity: Double = 0
    @State private var subtitleVisible: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("Enough.")
                    .font(.system(size: 72, weight: .black))
                    .foregroundColor(.white)
                    .tracking(-4)
                    .scaleEffect(wordScale)
                    .opacity(wordOpacity)

                Spacer()

                Text("No more wasted days")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.25))
                    .tracking(2.8)
                    .textCase(.uppercase)
                    .opacity(subtitleVisible ? 1 : 0)
                    .offset(y: subtitleVisible ? 0 : 8)
                    .animation(.easeOut(duration: 0.5), value: subtitleVisible)

                Spacer()
            }
            .padding(.bottom, 60)
            .padding(.horizontal, 44)

            tapHint("Tap to continue")
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            if active {
                DispatchQueue.main.async {
                    self.wordScale = 0.84
                    self.wordOpacity = 0
                    self.subtitleVisible = false

                    withAnimation(.spring(response: 0.68, dampingFraction: 0.72)) {
                        self.wordScale = 1
                        self.wordOpacity = 1
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.subtitleVisible = true
                    }
                }
            }
        }
    }
}

#Preview {
    EnoughCard(isActive: true)
        .preferredColorScheme(.dark)
}
