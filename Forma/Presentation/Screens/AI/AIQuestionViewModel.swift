//
//  AIQuestionViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/29/26.
//

import SwiftUI

// MARK: - AIQuestionsViewModel

@MainActor
final class AIQuestionsViewModel: ObservableObject {

    // MARK: - Published

    @Published var questions:  [AIQuestion] = []
    @Published var answers:    [String: AIAnswer] = [:]
    @Published var loadState:  LoadState = .loading
    @Published var aiMessage:  String = ""

    enum LoadState {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Dependencies

    private let repository:    AIRepositoryProtocol
    let userPreferences:       UserPreferences

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
        questions.allSatisfy { answers[$0.id]?.isAnswered == true }
    }

    var answeredCount: Int {
        answers.values.filter { $0.isAnswered }.count
    }

    // Binding for a specific question — used by AIQuestionRenderer
    func binding(for question: AIQuestion) -> Binding<AIAnswer> {
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

    // MARK: - Fetch questions from AI

    func fetchQuestions() async {
        loadState = .loading

        do {
            let response = try await repository.fetchQuestions(
                userPreferences: userPreferences
            )

            aiMessage = response.message ?? "A few quick questions to personalise your routine."
            questions = response.questions

            // Pre-populate empty answers
            for q in questions {
                answers[q.id] = AIAnswer(
                    questionId:     q.id,
                    selectedIds:    [],
                    selectedLabels: []
                )
            }

            loadState = .loaded

        } catch {
            loadState = .error(error.localizedDescription)
        }
    }

    // MARK: - Build enriched preferences
    // Called by the coordinator before navigating to AIGenerationView

    func buildEnrichedPreferences() -> UserPreferences {
        var enriched = userPreferences

        for (questionId, answer) in answers {
            guard let label = answer.firstLabel else { continue }
            switch questionId {
            case "work_style":  enriched.workStyle          = label
            case "exercise":    enriched.exerciseTime       = label
            case "lunch_break": enriched.lunchBreak         = label
            default:
                enriched.additionalContext =
                    (enriched.additionalContext ?? "")
                    + "\(questionId): \(label). "
            }
        }

        return enriched
    }
}
