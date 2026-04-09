import SwiftUI

struct StatCard: View {
    let value: String
    let unit: String
    let description: String
    let isActive: Bool

    @State private var numVisible = false
    @State private var unitVisible = false
    @State private var descVisible = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Text(value)
                    .font(.system(size: 110, weight: .black))
                    .foregroundColor(.white)
                    .tracking(-6)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .scaleEffect(numVisible ? 1 : 0.72)
                    .opacity(numVisible ? 1 : 0)
                    .animation(
                        .spring(response: 0.58, dampingFraction: 0.65),
                        value: numVisible
                    )

                Text(unit.uppercased())
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.40))
                    .tracking(3.2)
                    .padding(.top, 8)
                    .opacity(unitVisible ? 1 : 0)
                    .offset(y: unitVisible ? 0 : 8)
                    .animation(.easeOut(duration: 0.35).delay(0.22), value: unitVisible)

                Text(description)
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(.white.opacity(0.42))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .tracking(-0.3)
                    .padding(.top, 18)
                    .padding(.horizontal, 44)
                    .opacity(descVisible ? 1 : 0)
                    .offset(y: descVisible ? 0 : 8)
                    .animation(.easeOut(duration: 0.35).delay(0.40), value: descVisible)
            }
            tapHint("Tap to continue")
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            if active {
                numVisible = false
                unitVisible = false
                descVisible = false
                DispatchQueue.main.async {
                    numVisible = true
                    unitVisible = true
                    descVisible = true
                }
            }
        }
    }
}

#Preview {
    StatCard(
        value: "66",
        unit: "Days",
        description: "That's how long it takes to build a habit that no longer requires willpower.",
        isActive: true
    )
    .preferredColorScheme(.dark)
}
