//
//  AIGenerationSwiftUIView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import SwiftUI

struct AIGenerationSwiftUIView: View {
    @StateObject var viewModel: AIGenerationViewModel
    var coordinator: AICoordinator

    init(userPreferences: UserPreferences, coordinator: AICoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: AIGenerationViewModel(userPreferences: userPreferences))
    }

    var body: some View {
        ZStack {
            AIGenerationProgressView(phase: viewModel.phase)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Top navigation bar with status ──
                statusNavBar
                    .padding(.top, 56)
                    .padding(.horizontal, 24)

                // ── Routine table — primary content ──
                if !viewModel.newGeneratedRoutines.isEmpty {
                    routinePanel
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                // ── Create Account — floats above count, only when done ──
                if viewModel.phase == .done {
                    createAccountButton
                        .padding(.horizontal, 40)
                        .padding(.bottom, 24)
                        .transition(
                            .opacity.combined(with: .move(edge: .bottom))
                        )
                }

                // ── Count — anchored to bottom ──
                countView
                    .padding(.bottom, 52)
            }
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.82), value: viewModel.phase == .done)
        .task {
            await viewModel.startGeneration()
        }
    }
}

// MARK: - Subviews

extension AIGenerationSwiftUIView {

    // ── Nav bar ──
    private var statusNavBar: some View {
        HStack(alignment: .center) {
            Text("ROUTINES")
                .font(.system(size: 10, weight: .light))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.35))

            Spacer()

            HStack(spacing: 8) {
                StatusDot(isDone: viewModel.phase == .done)

                Text(statusLabel)
                    .font(.system(size: 10, weight: .light))
                    .tracking(3)
                    .foregroundStyle(.white.opacity(0.28))
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.4), value: statusLabel)
            }
        }
    }

    // ── Routine table ──
    private var routinePanel: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.newGeneratedRoutines.enumerated()), id: \.element.id) { index, routine in

                    RoutineRow(routine: routine, index: index)
                        .onTapGesture {
                            coordinator.showRoutineDetailView(routine: routine) { updated in
                                viewModel.newGeneratedRoutines[index] = updated
                            }
                        }
                        .onAppear {
                            
                        }

                    if index < viewModel.newGeneratedRoutines.count - 1 {
                        Rectangle()
                            .fill(.white.opacity(0.055))
                            .frame(height: 0.5)
                            .padding(.leading, 68)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            ShimmerOverlay(isActive: viewModel.phase != .done)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        )
    }

    // ── Create Account button ──
    private var createAccountButton: some View {
        Button {
            coordinator.didTapStartButton(
                with: viewModel.userPreferences,
                routines: viewModel.newGeneratedRoutines
            )
        } label: {
            HStack(spacing: 10) {
                Text("Create Account")
                    .font(.system(size: 13, weight: .light))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.88))

                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                ZStack {
                    // Frosted base
                    RoundedRectangle(cornerRadius: 26)
                        .fill(.white.opacity(0.055))

                    // Top-edge inner highlight — catches ambient light
                    RoundedRectangle(cornerRadius: 26)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.07), .clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )

                    // Hairline border
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(.white.opacity(0.12), lineWidth: 0.5)
                }
            )
        }
        .buttonStyle(CreateAccountButtonStyle())
    }

    // ── Bottom count ──
    private var countView: some View {
        VStack(spacing: 6) {
            if viewModel.newGeneratedRoutines.isEmpty {
                VStack(spacing: 4) {
                    Text("crafting your")
                        .font(.system(size: 13, weight: .ultraLight))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text("architecture")
                        .font(.system(size: 13, weight: .ultraLight))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .transition(.opacity)
            } else {
                VStack(spacing: 2) {
                    Text("\(viewModel.newGeneratedRoutines.count)")
                        .font(.system(size: 64, weight: .thin))
                        .foregroundStyle(.white.opacity(0.88))
                        .contentTransition(.numericText())
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.75),
                            value: viewModel.newGeneratedRoutines.count
                        )

                    Text("routines crafted")
                        .font(.system(size: 10, weight: .ultraLight))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.22))
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }

            if viewModel.phase == .done {
                Rectangle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 20, height: 0.5)
                    .padding(.top, 6)
                    .transition(.opacity)
            } else {
                BreathingLineView()
                    .frame(width: 24, height: 1)
                    .padding(.top, 6)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: viewModel.newGeneratedRoutines.isEmpty)
        .animation(.easeInOut(duration: 0.4), value: viewModel.phase == .done)
    }

    private var statusLabel: String {
        switch viewModel.phase {
        case .thinking:          return "THINKING"
        case .firstArrived:      return "FIRST READY"
        case .streaming(let n):  return "\(n) STREAMING"
        case .done:              return "COMPLETE"
        }
    }
}
