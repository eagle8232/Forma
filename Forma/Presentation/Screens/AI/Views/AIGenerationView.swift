//
//  AIGenerationSwiftUIView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import SwiftUI

struct AIGenerationView: View {

    @StateObject var viewModel: AIGenerationViewModel
    var coordinator: AICoordinator

    init(userPreferences: UserPreferences, coordinator: AICoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(
            wrappedValue: AIGenerationViewModel(userPreferences: userPreferences)
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                statusNavBar
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                Spacer()

                ScrollView(.vertical, showsIndicators: false) {
                    switch viewModel.questionPhase {
                    case .loading:
                        EmptyView()

                    case .asking, .transitioning:
                        questionPanel
                            .padding(.horizontal, 24)
                            .padding(.bottom, 32)

                    case .generating:
                        if !viewModel.newGeneratedRoutines.isEmpty {
                            routinePanel
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.questionPhase)

                if viewModel.questionPhase == .asking && viewModel.allAnswered {
                    continueButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                }

                if viewModel.isGenerationDone {
                    createAccountButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                }

                countView
                    .padding(.bottom, 56)
            }
        }
        .task(id: viewModel.phase) { await viewModel.start() }
    }
}

// MARK: - Nav Bar

extension AIGenerationView {

    private var statusNavBar: some View {
        HStack {
            Spacer()

            HStack(spacing: 8) {
                StatusDot(isDone: viewModel.isGenerationDone)

                Text(viewModel.statusLabel)
                    .font(.system(size: 8, weight: .ultraLight))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.2))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.statusLabel)
            }
        }
    }
}

// MARK: - Question Panel

extension AIGenerationView {

    private var questionPanel: some View {
        VStack(alignment: .leading, spacing: 32) {

            aiMessageHeader

            ForEach(
                Array(viewModel.questions.prefix(viewModel.visibleQuestionCount).enumerated()),
                id: \.element.id
            ) { i, question in
                questionRow(question: question, index: i)
            }
        }
    }

    private var aiMessageHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("FORMA AI")
                .font(.system(size: 7, weight: .ultraLight))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.15))

            Text(viewModel.aiMessage)
                .font(.system(size: 14, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.5))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func questionRow(question: AIQuestion, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(String(format: "%02d", index + 1))
                .font(.system(size: 8, weight: .ultraLight))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.1))

            Text(question.text)
                .font(.system(size: 16, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            AIQuestionRenderer(
                question: question,
                answer: viewModel.answerBinding(for: question),
                index: index + 1,
                accent: AppColor.accentPrimary
            )
        }
    }
}

// MARK: - Routine Panel

extension AIGenerationView {

    private var routinePanel: some View {
        VStack(spacing: 0) {
            ForEach(
                Array(viewModel.newGeneratedRoutines.enumerated()),
                id: \.element.id
            ) { index, routine in
                routineRow(routine: routine, index: index)
                    .onTapGesture {
                        guard viewModel.phase == .done else { return }
                        coordinator.showRoutineDetailView(routine: routine) { updated in
                            viewModel.updateRoutine(updated)
                        }
                    }

                if index < viewModel.newGeneratedRoutines.count - 1 {
                    Rectangle()
                        .fill(.white.opacity(0.04))
                        .frame(height: 0.5)
                        .padding(.leading, 48)
                }
            }
        }
    }

    private func routineRow(routine: RoutineBlock, index: Int) -> some View {
        HStack(spacing: 14) {
            Text(routine.icon)
                .font(.system(size: 18))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(1)

                Text("\(routine.startTime) – \(routine.endTime)")
                    .font(.system(size: 10, weight: .ultraLight))
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.2))
            }

            Spacer()

            Text("\(routine.tasks.count)")
                .font(.system(size: 9, weight: .ultraLight))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.12))
        }
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

// MARK: - Count View

extension AIGenerationView {

    private var countView: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.questionPhase {
                case .loading:
                    placeholderText("gathering", "questions")

                case .asking:
                    if viewModel.answeredCount == 0 {
                        placeholderText("answer", "to continue")
                    } else {
                        countNumber(
                            value: viewModel.answeredCount,
                            label: "answered"
                        )
                    }

                case .transitioning:
                    placeholderText("building your", "routine")

                case .generating:
                    if viewModel.newGeneratedRoutines.isEmpty {
                        placeholderText("crafting your", "architecture")
                    } else {
                        countNumber(
                            value: viewModel.newGeneratedRoutines.count,
                            label: "routines"
                        )
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: viewModel.questionPhase)

            Group {
                if viewModel.isGenerationDone || (viewModel.questionPhase == .asking && viewModel.allAnswered) {
                    Rectangle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 12, height: 0.5)
                        .transition(.opacity)
                } else {
                    BreathingLineView()
                        .frame(width: 20, height: 1)
                }
            }
            .padding(.top, 16)
            .animation(.easeInOut(duration: 0.4), value: viewModel.phase == .done)
        }
    }

    private func placeholderText(_ line1: String, _ line2: String) -> some View {
        VStack(spacing: 4) {
            Text(line1)
                .font(.system(size: 10, weight: .ultraLight))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.2))
            Text(line2)
                .font(.system(size: 10, weight: .ultraLight))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.2))
        }
        .transition(.opacity)
    }

    private func countNumber(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 64, weight: .thin))
                .tracking(-3)
                .foregroundStyle(.white.opacity(0.85))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: value)

            Text(label)
                .font(.system(size: 8, weight: .ultraLight))
                .tracking(5)
                .foregroundStyle(.white.opacity(0.15))
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }
}

// MARK: - Buttons

extension AIGenerationView {

    private var continueButton: some View {
        Button {
            Task { await viewModel.proceedToGeneration() }
        } label: {
            buttonLabel("Build my routine")
        }
        .buttonStyle(CreateAccountButtonStyle())
    }

    private var createAccountButton: some View {
        Button {
            coordinator.didTapStartButton(
                with: viewModel.userPreferences,
                routines: viewModel.newGeneratedRoutines
            )
        } label: {
            buttonLabel("Create Account")
        }
        .buttonStyle(CreateAccountButtonStyle())
    }

    private func buttonLabel(_ title: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 11, weight: .ultraLight))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.8))

            Image(systemName: "arrow.right")
                .font(.system(size: 9, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
    }
}
