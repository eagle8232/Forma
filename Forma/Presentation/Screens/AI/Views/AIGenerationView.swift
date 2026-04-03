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
            AIGenerationProgressView(phase: .done)
                .ignoresSafeArea()
            GrainOverlay().ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                statusNavBar
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                Spacer()

                // ── Panel — questions or routines ──
                ScrollView(.vertical) {
                    switch viewModel.questionPhase {
                    case .loading:
                        EmptyView()

                    case .asking, .transitioning:
                        questionPanel
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal:   .opacity.combined(with: .move(edge: .top))
                                )
                            )

                    case .generating:
                        if !viewModel.newGeneratedRoutines.isEmpty {
                            routinePanel
                                .padding(.horizontal, 20)
                                .padding(.bottom, 28)
                                .transition(
                                    .asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal:   .opacity
                                    )
                                )
                        }
                    }
                }
                .animation(.spring(response: 0.55, dampingFraction: 0.82), value: viewModel.questionPhase)

                // ── Continue button ──
                if viewModel.questionPhase == .asking && viewModel.allAnswered {
                    continueButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        .transition(.opacity.combined(with: .offset(y: 12)))
                }

                // ── Create Account button ──
                if viewModel.isGenerationDone {
                    createAccountButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                        .transition(.opacity.combined(with: .offset(y: 16)))
                }

                countView
                    .padding(.bottom, 52)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: viewModel.phase == .done)
        .animation(.easeOut(duration: 0.5), value: viewModel.newGeneratedRoutines.count)
        .animation(.easeInOut(duration: 0.4), value: viewModel.allAnswered)
        .task { await viewModel.start() }
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
                    .font(.system(size: 9, weight: .ultraLight))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.25))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: viewModel.statusLabel)
            }
        }
    }
}

// MARK: - Question Panel

extension AIGenerationView {

    private var questionPanel: some View {
        VStack(spacing: 0) {

            aiMessageHeader
                .padding(.horizontal, 20)
                .padding(.vertical, 18)

            Rectangle()
                .fill(.white.opacity(0.05))
                .frame(height: 0.5)

            ForEach(
                Array(viewModel.questions.prefix(viewModel.visibleQuestionCount).enumerated()),
                id: \.element.id
            ) { i, question in
                questionRow(question: question, index: i)

                if i < min(viewModel.visibleQuestionCount, viewModel.questions.count) - 1 {
                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .frame(height: 0.5)
                        .padding(.leading, 20)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.025))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            ShimmerOverlay(isActive: viewModel.questionPhase == .loading || viewModel.questionPhase == .transitioning)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }

    private var aiMessageHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.04))
                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 0.5))
                    .frame(width: 28, height: 28)

                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.4))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("FORMA AI")
                    .font(.system(size: 8, weight: .ultraLight))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.2))

                Text(viewModel.aiMessage)
                    .font(.system(size: 12, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private func questionRow(question: AIQuestion, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(String(format: "%02d", index + 1))
                    .font(.system(size: 9, weight: .ultraLight))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.15))

                Text(question.text)
                    .font(.system(size: 13, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }

            AIQuestionRenderer(
                question: question,
                answer: viewModel.answerBinding(for: question),
                index: index + 1,
                accent: AppColor.accentPrimary
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
                        .fill(.white.opacity(0.05))
                        .frame(height: 0.5)
                        .padding(.leading, 52)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.025))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            ShimmerOverlay(isActive: viewModel.phase != .done)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }

    private func routineRow(routine: RoutineBlock, index: Int) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(uiColor: UIColor(hex: routine.accentColor)).opacity(0.75))
                .frame(width: 2, height: 22)
                .padding(.leading, 20)

            Text(routine.icon)
                .font(.system(size: 16))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(routine.title)
                    .font(.system(size: 13, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(1)

                Text("\(routine.startTime) – \(routine.endTime)")
                    .font(.system(size: 10, weight: .ultraLight))
                    .tracking(0.3)
                    .foregroundStyle(.white.opacity(0.22))
            }

            Spacer()

            Text("\(routine.tasks.count)")
                .font(.system(size: 9, weight: .ultraLight))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.15))
                .padding(.trailing, 20)
        }
        .frame(height: 58)
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
                            label: viewModel.answeredCount == 1 ? "answered" : "answered"
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
                        .fill(.white.opacity(0.14))
                        .frame(width: 16, height: 0.5)
                        .transition(.opacity)
                } else {
                    BreathingLineView()
                        .frame(width: 24, height: 1)
                }
            }
            .padding(.top, 16)
            .animation(.easeInOut(duration: 0.4), value: viewModel.phase == .done)
        }
    }

    private func placeholderText(_ line1: String, _ line2: String) -> some View {
        VStack(spacing: 5) {
            Text(line1)
                .font(.system(size: 12, weight: .ultraLight))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.28))
            Text(line2)
                .font(.system(size: 12, weight: .ultraLight))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.28))
        }
        .transition(.opacity)
    }

    private func countNumber(value: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 72, weight: .thin))
                .tracking(-4)
                .foregroundStyle(.white.opacity(0.88))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.5, dampingFraction: 0.75), value: value)

            Text(label)
                .font(.system(size: 9, weight: .ultraLight))
                .tracking(5)
                .foregroundStyle(.white.opacity(0.16))
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
                .font(.system(size: 12, weight: .ultraLight))
                .tracking(3)
                .foregroundStyle(.white.opacity(0.82))

            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(LinearGradient(
                            colors: [.white.opacity(0.055), .clear],
                            startPoint: .top,
                            endPoint: .center
                        ))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(.white.opacity(0.09), lineWidth: 0.5)
                )
        )
    }
}
