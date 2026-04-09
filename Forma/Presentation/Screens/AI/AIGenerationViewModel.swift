//
//  AIGenerationViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import SwiftUI

// MARK: - AIGenerationViewModel

@MainActor
final class AIGenerationViewModel: ObservableObject {

    // MARK: - Generation phase (existing)

    enum GenerationPhase: Equatable {
        case thinking
        case firstArrived
        case streaming(Int)
        case done

        static func == (lhs: GenerationPhase, rhs: GenerationPhase) -> Bool {
            switch (lhs, rhs) {
            case (.thinking, .thinking),
                 (.firstArrived, .firstArrived),
                 (.done, .done):          return true
            case (.streaming(let a), .streaming(let b)): return a == b
            default:                      return false
            }
        }
    }

    // MARK: - Question phase

    enum QuestionPhase: Equatable {
        case loading
        case asking
        case transitioning
        case generating
    }

    // MARK: - Published

    @Published var phase:                  GenerationPhase = .thinking
    @Published var questionPhase:          QuestionPhase   = .loading
    @Published var newGeneratedRoutines:   [RoutineBlock]  = []
    @Published var questions:              [AIQuestion]    = []
    @Published var answers:                [String: AIAnswer] = [:]
    @Published var aiMessage:              String          = ""
    @Published var visibleQuestionCount:    Int             = 0
    
    // MARK: - Private
    
    private var hasStarted = false

    // MARK: - Input

    var userPreferences: UserPreferences

    // MARK: - Dependencies

    private let repository: AIRepositoryProtocol

    // MARK: - Init

    init(
        userPreferences: UserPreferences,
        repository: AIRepositoryProtocol = DependencyContainer.shared.resolve() ?? AIRepository()
    ) {
        self.userPreferences = userPreferences
        self.repository      = repository
    }

    // MARK: - Computed

    var allAnswered: Bool {
        !questions.isEmpty && questions.allSatisfy {
            answers[$0.id]?.isAnswered == true
        }
    }

    var answeredCount: Int {
        answers.values.filter { $0.isAnswered }.count
    }

    var statusLabel: String {
        switch questionPhase {
        case .loading:       return "THINKING"
        case .asking:
            return answeredCount == 0 ? "QUESTIONS" : "\(answeredCount) ANSWERED"
        case .transitioning: return "READY"
        case .generating:
            switch phase {
            case .thinking:          return "THINKING"
            case .firstArrived:      return "READY"
            case .streaming(let n):  return "\(n) CRAFTED"
            case .done:              return "COMPLETE"
            }
        }
    }

    var isGenerationDone: Bool {
        questionPhase == .generating && phase == .done
    }

    // MARK: - Answer binding

    func answerBinding(for question: AIQuestion) -> Binding<AIAnswer> {
        Binding(
            get: {
                self.answers[question.id] ?? AIAnswer(
                    questionId:     question.id,
                    selectedIds:    [],
                    selectedLabels: []
                )
            },
            set: { self.answers[question.id] = $0 }
        )
    }

    // MARK: - Main entry point

    func start() async {
        guard !hasStarted else { return }
        hasStarted = true
        guard questions.isEmpty else { return }
        await fetchQuestions()
    }

    // MARK: - Fetch questions

    private func fetchQuestions() async {
        questionPhase = .loading

        do {
            let response = try await repository.fetchQuestions(userPreferences: userPreferences)

            aiMessage = response.message ?? "A few quick questions to personalise your routine."
            questions  = response.questions

            for q in questions {
                answers[q.id] = AIAnswer(questionId: q.id, selectedIds: [], selectedLabels: [])
            }

            withAnimation(.easeOut(duration: 0.4)) {
                questionPhase = .asking
            }

            // Stagger question reveal
            for i in 0..<questions.count {
                try? await Task.sleep(for: .milliseconds(200))
                withAnimation(.easeOut(duration: 0.4)) {
                    visibleQuestionCount = i + 1
                }
            }

        } catch {
            // Questions failed — skip straight to generation
            await beginGeneration()
        }
    }

    // MARK: - Proceed after questions answered

    func proceedToGeneration() async {
        withAnimation(.easeInOut(duration: 0.5)) {
            questionPhase = .transitioning
        }

        try? await Task.sleep(for: .milliseconds(400))

        withAnimation(.easeInOut(duration: 0.5)) {
            questionPhase = .generating
        }

        await beginGeneration()
    }

    // MARK: - Generation

    func startGeneration() async {
        await beginGeneration()
    }

    private func beginGeneration() async {
        mergeAnswersIntoPreferences()
        phase = .thinking

        let stream = repository.generateRoutines(userPreferences: userPreferences)

        for await routine in stream {
            newGeneratedRoutines.append(routine)

            withAnimation {
                if newGeneratedRoutines.count == 1 {
                    phase = .firstArrived
                } else {
                    phase = .streaming(newGeneratedRoutines.count)
                }
            }
        }

        withAnimation { phase = .done }
    }

    // MARK: - Merge answers into preferences

    private func mergeAnswersIntoPreferences() {
        for (questionId, answer) in answers {
            guard let label = answer.firstLabel else { continue }
            switch questionId {
            case "work_style":  userPreferences.workStyle         = label
            case "exercise":    userPreferences.exerciseTime      = label
            case "lunch_break": userPreferences.lunchBreak        = label
            default:
                userPreferences.additionalContext =
                    (userPreferences.additionalContext ?? "")
                    + "\(questionId): \(label). "
            }
        }
    }

    // MARK: - Update routine (called from coordinator after edit)

    func updateRoutine(_ updated: RoutineBlock) {
        guard let i = newGeneratedRoutines.firstIndex(where: { $0.id == updated.id }) else { return }
        newGeneratedRoutines[i] = updated
        DependencyContainer.shared.updateRoutines(newGeneratedRoutines)
    }
}
