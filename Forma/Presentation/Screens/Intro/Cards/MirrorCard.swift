import SwiftUI

struct MirrorCard: View {
    let isActive: Bool

    @State private var cursorIndex: Int = 0
    @State private var typingTimer: Timer?
    @State private var hasStartedTyping: Bool = false

    private let fullText = "You already know what you should be doing."

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    Text(String(fullText.prefix(cursorIndex)))
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                    +
                    Text(cursorIndex < fullText.count ? "|" : "")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, 44)

            tapHint("Tap to continue")
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onAppear {
            if isActive && !hasStartedTyping {
                startTyping()
            }
        }
        .onChange(of: isActive) { active in
            if active && !hasStartedTyping {
                startTyping()
            }
        }
        .onDisappear {
            typingTimer?.invalidate()
            typingTimer = nil
        }
    }

    private func startTyping() {
        hasStartedTyping = true
        cursorIndex = 0
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            if cursorIndex <= fullText.count {
                cursorIndex += 1
            }
            if cursorIndex > fullText.count {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    MirrorCard(isActive: true)
        .preferredColorScheme(.dark)
}
