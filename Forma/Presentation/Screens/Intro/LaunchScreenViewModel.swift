import SwiftUI
import UIKit

@MainActor
final class LaunchScreenViewModel: ObservableObject {

    @Published var currentWord: String = ""
    @Published var wordVisible: Bool = false
    @Published var isComplete: Bool = false

    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)

    func start() {
        impactGenerator.prepare()
        Task {
            await runFlashPhase()
        }
    }

    private func runFlashPhase() async {
        let words: [String] = [
            "WAKE", "UP.", "WORK.", "RESIST.",
            "SHOW", "UP.", "BUILD.",
            "EVERY", "DAY.", "NO", "EXCUSES.", "DISCIPLINE."
        ]
        let duration: Double = 1.5 / Double(words.count)

        for word in words {
            currentWord = word
            wordVisible = false
            impactGenerator.impactOccurred()
            try? await Task.sleep(for: .milliseconds(16))

            withAnimation(.easeOut(duration: 0.04)) {
                wordVisible = true
            }

            try? await Task.sleep(for: .seconds(duration))
        }

        try? await Task.sleep(for: .milliseconds(200))
        withAnimation {
            isComplete = true
        }
    }
}
