import SwiftUI

struct ContrastCard: View {
    let isActive: Bool
    @State private var topVisible = false
    @State private var bottomVisible = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white
                VStack(spacing: 6) {
                    Text("Motivation")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(.black)
                        .tracking(-1.3)
                        .textCase(.uppercase)
                    Text("comes and goes")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.black.opacity(0.32))
                        .tracking(1.8)
                        .textCase(.uppercase)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(topVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.38), value: topVisible)

            ZStack {
                Color.black
                    .overlay(Rectangle().fill(Color.white.opacity(0.10)).frame(height: 1), alignment: .top)
                VStack(spacing: 6) {
                    Text("Discipline")
                        .font(.system(size: 44, weight: .black))
                        .foregroundColor(.white)
                        .tracking(-1.3)
                        .textCase(.uppercase)
                    Text("stays forever")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.28))
                        .tracking(1.8)
                        .textCase(.uppercase)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(bottomVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.38).delay(0.18), value: bottomVisible)
        }
        .ignoresSafeArea()
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .overlay(tapHint("Tap to continue"), alignment: .bottom)
        .onChange(of: isActive) { active in
            if active {
                topVisible = false
                bottomVisible = false
                DispatchQueue.main.async {
                    topVisible = true
                    bottomVisible = true
                }
            }
        }
    }
}

#Preview {
    ContrastCard(isActive: true)
        .preferredColorScheme(.dark)
}
