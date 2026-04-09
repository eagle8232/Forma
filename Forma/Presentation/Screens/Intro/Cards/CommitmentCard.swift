import SwiftUI

struct CommitmentCard: View {
    let isActive: Bool

    @State private var barHeight: CGFloat = 0
    @State private var commitVisible: Bool = false

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
                .frame(height: 160)
                .padding(.leading, 28)

                VStack(alignment: .leading, spacing: 10) {
                    Text("I am done waiting")
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

                    Text("for motivation.")
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

                    Text("I choose discipline.")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white.opacity(0.45))
                        .tracking(-0.4)
                        .lineSpacing(2)
                        .opacity(isActive ? 1 : 0)
                        .offset(y: isActive ? 0 : 14)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.82).delay(0.50),
                            value: isActive
                        )
                }
                .padding(.leading, 20)

                Spacer()
            }
            .padding(.trailing, 38)

            VStack {
                Spacer()
                Text("TAP TO COMMIT")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2.6)
                    .foregroundColor(.white.opacity(commitVisible ? 0.22 : 0.08))
                    .padding(.bottom, 50)
                    .animation(.easeInOut(duration: 0.6), value: commitVisible)
            }
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            if active {
                barHeight = 0
                commitVisible = false
                DispatchQueue.main.async {
                    barHeight = 100
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        commitVisible = true
                    }
                }
            } else {
                barHeight = 0
                commitVisible = false
            }
        }
    }
}

#Preview {
    CommitmentCard(isActive: true)
        .preferredColorScheme(.dark)
}
