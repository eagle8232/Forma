import SwiftUI

struct IntroView: View {

    @StateObject private var launchViewModel = LaunchScreenViewModel()
    @State private var showIntroFlow: Bool = false

    var onComplete: (([String: Any]) -> Void)?

    var body: some View {
        ZStack {
            if showIntroFlow {
                FormaIntroFlowView { answers in
                    onComplete?(answers)
                }
                .transition(.opacity)
            } else {
                launchScreenContent
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }

    private var launchScreenContent: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if launchViewModel.wordVisible {
                Text(launchViewModel.currentWord)
                    .font(.system(size: 56, weight: .black))
                    .tracking(-2.0)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .scaleEffect(launchViewModel.wordVisible ? 1.0 : 0.88)
                    .id(launchViewModel.currentWord)
            }
        }
        .onAppear {
            launchViewModel.start()
        }
        .onChange(of: launchViewModel.isComplete) { _, isComplete in
            if isComplete {
                withAnimation(.easeOut(duration: 0.3)) {
                    showIntroFlow = true
                }
            }
        }
    }
}
