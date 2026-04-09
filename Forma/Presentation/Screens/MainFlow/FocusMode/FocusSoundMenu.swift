import SwiftUI

struct FocusSoundMenu: View {

    @Binding var activeSound: FocusModeViewModel.SoundEnvironment
    @Binding var menuOpen: Bool
    var onAITap: () -> Void

    @State private var aiRingScale: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Button(action: onAITap) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#A259FF").opacity(0.25),
                                    Color(hex: "#6428C8").opacity(0.32),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(Color(hex: "#A259FF").opacity(0.40), lineWidth: 1))
                        .frame(width: 50, height: 50)
                        .shadow(color: Color(hex: "#A259FF").opacity(0.25), radius: 18)
                        .shadow(color: Color(hex: "#A259FF").opacity(0.10), radius: 36)

                    Circle()
                        .stroke(Color(hex: "#A259FF").opacity(0.14), lineWidth: 1)
                        .frame(width: 59, height: 59)
                        .scaleEffect(aiRingScale)
                        .animation(
                            .easeInOut(duration: 3).repeatForever(autoreverses: true),
                            value: aiRingScale
                        )

                    Text("✦")
                        .font(.system(size: 19))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            .onAppear { aiRingScale = 1.1 }

            ZStack(alignment: .bottomTrailing) {
                if menuOpen {
                    VStack(alignment: .trailing, spacing: 8) {
                        ForEach(
                            Array(FocusModeViewModel.SoundEnvironment.allCases.enumerated()),
                            id: \.element.id
                        ) { index, sound in
                            soundOption(sound, index: index)
                        }
                    }
                    .padding(.bottom, 60)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .move(edge: .bottom))
                        )
                    )
                }

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        menuOpen.toggle()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(menuOpen
                                  ? Color.white.opacity(0.10)
                                  : Color.white.opacity(0.06))
                            .overlay(
                                Circle().stroke(
                                    Color.white.opacity(menuOpen ? 0.20 : 0.10),
                                    lineWidth: 1
                                )
                            )
                            .frame(width: 50, height: 50)

                        Text(activeSound.emoji)
                            .font(.system(size: 22))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func soundOption(
        _ sound: FocusModeViewModel.SoundEnvironment,
        index: Int
    ) -> some View {
        HStack(spacing: 10) {
            Text(sound.label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.70))
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    activeSound = sound
                    menuOpen = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(activeSound == sound
                              ? Color(hex: "#A259FF").opacity(0.14)
                              : Color.white.opacity(0.06))
                        .overlay(
                            Circle().stroke(
                                activeSound == sound
                                    ? Color(hex: "#A259FF").opacity(0.45)
                                    : Color.white.opacity(0.10),
                                lineWidth: 1
                            )
                        )
                        .frame(width: 44, height: 44)

                    Text(sound.emoji)
                        .font(.system(size: 20))
                }
            }
            .buttonStyle(.plain)
        }
        .transition(
            .asymmetric(
                insertion: .opacity
                    .combined(with: .offset(y: CGFloat(index) * 4))
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.8)
                        .delay(Double(FocusModeViewModel.SoundEnvironment.allCases.count - 1 - index) * 0.04)
                    ),
                removal: .opacity
                    .animation(.easeIn(duration: 0.15))
            )
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            Spacer()
            FocusSoundMenu(
                activeSound: .constant(.rain),
                menuOpen: .constant(true),
                onAITap: {}
            )
            .padding()
        }
    }
}
