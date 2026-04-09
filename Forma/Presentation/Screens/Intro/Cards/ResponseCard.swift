import SwiftUI

struct ResponseCard: View {
    let line1: String
    let line2: String
    var line3: String? = nil
    let isActive: Bool

    @State private var barHeight: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            HStack(alignment: .center, spacing: 0) {

                VStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 3, height: barHeight)
                        .animation(.easeOut(duration: 0.52), value: barHeight)
                }
                .frame(height: 200)
                .padding(.leading, 28)

                VStack(alignment: .leading, spacing: 10) {
                    Text(line1)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.7)
                        .lineSpacing(2)
                        .opacity(isActive ? 1 : 0)
                        .offset(y: isActive ? 0 : 14)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.82).delay(0.18),
                            value: isActive
                        )

                    Text(line2)
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white.opacity(0.45))
                        .tracking(-0.4)
                        .lineSpacing(2)
                        .opacity(isActive ? 1 : 0)
                        .offset(y: isActive ? 0 : 14)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.82).delay(0.34),
                            value: isActive
                        )

                    if let l3 = line3 {
                        Text(l3)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.28))
                            .tracking(0.2)
                            .padding(.top, 8)
                            .opacity(isActive ? 1 : 0)
                            .animation(.easeOut(duration: 0.4).delay(0.54), value: isActive)
                    }
                }
                .padding(.leading, 20)

                Spacer()
            }
            tapHint("Tap to continue")
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            barHeight = active ? 88 : 0
        }
    }
}

#Preview {
    ResponseCard(
        line1: "A strong window to build from.",
        line2: "Forma will structure your morning for maximum output.",
        isActive: true
    )
    .preferredColorScheme(.dark)
}
