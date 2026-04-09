import SwiftUI

struct FormaIntroProgressBar: View {
    let fraction: Double

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.clear).frame(height: 2)
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geo.size.width * fraction, height: 2)
                        .cornerRadius(1)
                        .animation(.spring(response: 0.38, dampingFraction: 0.8), value: fraction)
                }
            }
            .frame(height: 2)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        FormaIntroProgressBar(fraction: 0.5)
    }
    .preferredColorScheme(.dark)
}
