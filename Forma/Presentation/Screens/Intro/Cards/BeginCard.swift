import SwiftUI

struct BeginCard: View {
    let isActive: Bool
    var onBegin: () -> Void

    @State private var btnVisible = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 28) {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                            .frame(width: 144, height: 144)
                            .scaleEffect(btnVisible ? 2.15 : 1)
                            .opacity(btnVisible ? 0 : 0.4)
                            .animation(
                                .easeOut(duration: 3.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 1.15),
                                value: btnVisible
                            )
                    }

                    Circle()
                        .stroke(Color.white.opacity(0.62), lineWidth: 1.5)
                        .frame(width: 144, height: 144)
                    Text("Begin")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .tracking(2.6)
                        .textCase(.uppercase)
                }
                .frame(width: 160, height: 160)
                .contentShape(Circle())
                .onTapGesture {
                    onBegin()
                }

                Text("Your routine starts now")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.22))
                    .tracking(3.2)
                    .textCase(.uppercase)
                    .opacity(btnVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: btnVisible)
            }
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .onChange(of: isActive) { active in
            if active {
                btnVisible = false
                DispatchQueue.main.async {
                    btnVisible = true
                }
            } else {
                btnVisible = false
            }
        }
    }
}

#Preview {
    BeginCard(isActive: true, onBegin: {})
        .preferredColorScheme(.dark)
}
