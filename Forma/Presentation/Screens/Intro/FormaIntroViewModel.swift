import SwiftUI

@MainActor
final class FormaIntroViewModel: ObservableObject {

    @Published var currentIndex: Int = 0
    @Published var isTransitioning: Bool = false

    let totalCards: Int = 14

    var progressFraction: Double {
        Double(currentIndex + 1) / Double(totalCards)
    }

    enum WakeAnswer { case early, mid, late }
    enum StruggleAnswer { case motivation, distracted, forgetting, starting }
    enum GoalAnswer { case deepwork, exercise, sleep, morning }

    @Published var wakeAnswer: WakeAnswer = .mid
    @Published var struggleAnswer: StruggleAnswer = .motivation
    @Published var goalAnswer: GoalAnswer = .deepwork

    @Published var response1Line1: String = ""
    @Published var response1Line2: String = ""
    @Published var response2Line1: String = ""
    @Published var response2Line2: String = ""
    @Published var response3Line1: String = ""
    @Published var response3Line2: String = ""
    @Published var response3Line3: String = ""

    var onComplete: (([String: Any]) -> Void)?

    private let questionCardIndices: Set<Int> = [4, 6, 8]

    var currentCardIsQuestion: Bool {
        questionCardIndices.contains(currentIndex)
    }

    func advance() {
        guard !isTransitioning else { return }
        guard currentIndex < totalCards - 1 else { return }
        guard !currentCardIsQuestion else { return }
        goTo(currentIndex + 1)
    }

    func goTo(_ index: Int) {
        guard !isTransitioning else { return }
        isTransitioning = true
        withAnimation(.easeInOut(duration: 0.2)) {
            currentIndex = index
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.isTransitioning = false
        }
    }

    func answerWakeTime(_ answer: WakeAnswer) {
        wakeAnswer = answer
        switch answer {
        case .early:
            response1Line1 = "You already have the hardest habit."
            response1Line2 = "Forma will build everything else on top of it."
        case .mid:
            response1Line1 = "A strong window to build from."
            response1Line2 = "Forma will structure your morning for maximum output."
        case .late:
            response1Line1 = "Most performers are 2 hours in by then."
            response1Line2 = "That changes today. Forma will get you there."
        }
        goTo(5)
    }

    func answerStruggle(_ answer: StruggleAnswer) {
        struggleAnswer = answer
        switch answer {
        case .motivation:
            response2Line1 = "Motivation is a feeling."
            response2Line2 = "Forma replaces it with system."
        case .distracted:
            response2Line1 = "Deep focus is a learnable skill."
            response2Line2 = "Forma's Focus Mode is built for exactly this."
        case .forgetting:
            response2Line1 = "Out of sight, out of mind."
            response2Line2 = "Forma's smart reminders will change that."
        case .starting:
            response2Line1 = "Starting is easy. Finishing is the skill."
            response2Line2 = "Forma breaks every routine into completable steps."
        }
        goTo(7)
    }

    func answerGoal(_ answer: GoalAnswer) {
        goalAnswer = answer
        let goalName: String
        switch answer {
        case .deepwork:  goalName = "Deep Work & Focus"
        case .exercise:  goalName = "Exercise & Movement"
        case .sleep:     goalName = "Better Sleep"
        case .morning:   goalName = "Morning Routine"
        }
        response3Line1 = "Forma will build your first"
        response3Line2 = "\(goalName) routine."
        response3Line3 = "Ready in seconds after you begin."
        goTo(9)
    }

    func complete() {
        let answers: [String: Any] = [
            "wakeAnswer": wakeAnswer,
            "struggleAnswer": struggleAnswer,
            "goalAnswer": goalAnswer,
        ]
        onComplete?(answers)
    }
}
