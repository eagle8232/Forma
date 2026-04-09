import SwiftUI

struct FormaIntroFlowView: View {

    @StateObject private var vm = FormaIntroViewModel()
    var onComplete: (([String: Any]) -> Void)?

    @State private var flashOpacity: Double = 0

    @State private var expandScale: CGFloat = 1
    @State private var expandOpacity: Double = 0
    @State private var showOnboarding: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            MirrorCard(isActive: vm.currentIndex == 0)
            ContrastCard(isActive: vm.currentIndex == 1)
            KineticCard(isActive: vm.currentIndex == 2)
            StatCard(value: "66", unit: "Days",
                     description: "That's how long it takes to build a habit that no longer requires willpower.",
                     isActive: vm.currentIndex == 3)

            QuestionCard(
                questionNumber: "Question 1 of 3",
                title: "When do you usually wake up?",
                options: [
                    QuestionOption(label: "Before 6AM", emoji: "🌅") { vm.answerWakeTime(.early) },
                    QuestionOption(label: "6AM – 8AM")                { vm.answerWakeTime(.mid)  },
                    QuestionOption(label: "After 8AM")                { vm.answerWakeTime(.late) },
                ],
                isActive: vm.currentIndex == 4
            )

            ResponseCard(line1: vm.response1Line1, line2: vm.response1Line2,
                         isActive: vm.currentIndex == 5)

            QuestionCard(
                questionNumber: "Question 2 of 3",
                title: "What usually stops you?",
                options: [
                    QuestionOption(label: "Losing motivation")         { vm.answerStruggle(.motivation) },
                    QuestionOption(label: "Getting distracted")        { vm.answerStruggle(.distracted) },
                    QuestionOption(label: "Forgetting routines")       { vm.answerStruggle(.forgetting) },
                    QuestionOption(label: "Starting but not finishing"){ vm.answerStruggle(.starting)   },
                ],
                isActive: vm.currentIndex == 6
            )

            ResponseCard(line1: vm.response2Line1, line2: vm.response2Line2,
                         isActive: vm.currentIndex == 7)

            QuestionCard(
                questionNumber: "Question 3 of 3",
                title: "What matters most to you right now?",
                options: [
                    QuestionOption(label: "Deep work & focus")   { vm.answerGoal(.deepwork) },
                    QuestionOption(label: "Exercise & movement")  { vm.answerGoal(.exercise) },
                    QuestionOption(label: "Better sleep")         { vm.answerGoal(.sleep)    },
                    QuestionOption(label: "Morning routine")      { vm.answerGoal(.morning)  },
                ],
                isActive: vm.currentIndex == 8
            )

            ResponseCard(
                line1: vm.response3Line1,
                line2: vm.response3Line2,
                line3: vm.response3Line3,
                isActive: vm.currentIndex == 9
            )

            StatCard(value: "73%", unit: "Completion rate",
                     description: "Average Forma user completes 73% of their daily routines by week three.",
                     isActive: vm.currentIndex == 10)

            CommitmentCard(isActive: vm.currentIndex == 11)
            EnoughCard(isActive: vm.currentIndex == 12)
            BeginCard(isActive: vm.currentIndex == 13, onBegin: triggerBegin)

            FormaIntroProgressBar(fraction: vm.progressFraction)
                .opacity(vm.currentIndex == 13 ? 0 : 1)
                .animation(.easeOut(duration: 0.3), value: vm.currentIndex)

            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)
                .zIndex(50)

            Circle()
                .fill(Color.white)
                .frame(width: 144, height: 144)
                .scaleEffect(expandScale)
                .opacity(expandOpacity)
                .zIndex(60)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !vm.currentCardIsQuestion else { return }
            guard vm.currentIndex < 13 else { return }
            triggerFlash { vm.advance() }
        }
        .onAppear {
            vm.onComplete = { answers in
                onComplete?(answers)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .ignoresSafeArea()
    }

    private func triggerFlash(_ completion: @escaping () -> Void) {
        flashOpacity = 0.5
        withAnimation(.easeOut(duration: 0.18)) {
            flashOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.055) {
            completion()
        }
    }

    private func triggerBegin() {
        expandOpacity = 1
        expandScale = 1
        withAnimation(.spring(response: 0.68, dampingFraction: 0.88)) {
            expandScale = 11
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) {
            withAnimation(.easeOut(duration: 0.44)) { expandOpacity = 0 }
            showOnboarding = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                vm.complete()
            }
        }
    }
}

#Preview {
    FormaIntroFlowView { answers in
        print("Intro complete. Answers:", answers)
    }
}
