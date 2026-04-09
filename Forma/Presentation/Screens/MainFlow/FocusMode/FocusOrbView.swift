import SwiftUI

struct FocusOrbView: View {

    let sound: FocusModeViewModel.SoundEnvironment
    let insightText: String
    let insightPhase: FocusModeViewModel.InsightPhase

    @State private var floating = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            sound.orbInnerColor,
                            sound.orbOuterColor,
                        ]),
                        center: UnitPoint(x: 0.4, y: 0.35),
                        startRadius: 0,
                        endRadius: 98
                    )
                )
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: sound.glowColor, radius: 40, x: 0, y: 0)
                .shadow(color: sound.glowColor.opacity(0.4), radius: 80, x: 0, y: 0)
                .animation(.easeInOut(duration: 1.2), value: sound)

            Text(sound.emoji)
                .font(.system(size: 72))
                .shadow(color: .black.opacity(0.35), radius: 16, y: 6)
                .offset(y: floating ? -6 : 0)
                .scaleEffect(floating ? 1.04 : 1.0)
                .animation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                    value: floating
                )
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.7).combined(with: .opacity),
                        removal: .scale(scale: 0.7).combined(with: .opacity)
                    )
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: sound)

            if insightPhase != .hidden {
                Text(insightText)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 22)
                    .shadow(color: Color.black.opacity(0.5), radius: 8)
                    .opacity(insightOpacity)
                    .offset(y: insightOffsetY)
                    .scaleEffect(insightScale)
                    .blur(radius: insightBlur)
                    .animation(
                        .spring(response: 0.7, dampingFraction: 0.8),
                        value: insightPhase
                    )
            }
        }
        .frame(width: 196, height: 196)
        .clipShape(Circle())
        .onAppear { floating = true }
    }

    private var insightOpacity: Double {
        switch insightPhase {
        case .hidden:  return 0
        case .entering: return 1
        case .floating: return 1
        case .leaving: return 0
        }
    }

    private var insightOffsetY: CGFloat {
        switch insightPhase {
        case .hidden:  return 16
        case .entering: return 0
        case .floating: return -6
        case .leaving: return -18
        }
    }

    private var insightScale: CGFloat {
        switch insightPhase {
        case .hidden:  return 0.88
        case .entering: return 1.0
        case .floating: return 1.0
        case .leaving: return 0.92
        }
    }

    private var insightBlur: CGFloat {
        switch insightPhase {
        case .hidden:  return 4
        case .entering: return 0
        case .floating: return 0
        case .leaving: return 3
        }
    }
}

#Preview {
    FocusOrbView(
        sound: .rain,
        insightText: "You're in\nthe zone",
        insightPhase: .floating
    )
}
