//
//  FocusModeView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/6/26.
//

import SwiftUI

struct FocusModeView: View {

    @StateObject private var vm: FocusModeViewModel
    var onStepAway: (RoutineTask) -> Void

    @State private var breatheCueOpacity: Double = 0.3
    @State private var accentDotScale: CGFloat = 1.0

    init(
        task: RoutineTask,
        routineName: String,
        profession: String,
        onStepAway: @escaping (RoutineTask) -> Void
    ) {
        _vm = StateObject(wrappedValue: FocusModeViewModel(
            task: task,
            routineName: routineName,
            profession: profession
        ))
        self.onStepAway = onStepAway
    }

    var body: some View {
        ZStack {
            Color(hex: "#030303").ignoresSafeArea()

            RadialGradient(
                colors: [vm.activeSound.ambientColor, .clear],
                center: .center,
                startRadius: 0,
                endRadius: 220
            )
            .frame(width: 380, height: 380)
            .blur(radius: 40)
            .animation(.easeInOut(duration: 1.4), value: vm.activeSound)
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                progressThread

                statusBar

                taskIdentity

                Spacer()

                FocusOrbView(
                    sound: vm.activeSound,
                    insightText: vm.currentInsight,
                    insightPhase: vm.insightPhase
                )

                timerSection

                Spacer()
            }

            stepAwayButton

            soundMenuButton

            tapToDismissMenu

            aiOverlay
        }
        .sheet(isPresented: $vm.showStepAway) {
            FocusExitSheet(
                task: vm.task,
                elapsedMinutes: vm.elapsedMinutes,
                onSave: { task in onStepAway(task) },
                onStayIn: { vm.showStepAway = false }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color(hex: "#0B0B0B"))
        }
        .onAppear { vm.onAppear() }
        .onDisappear { vm.onDisappear() }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .statusBarHidden(false)
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Progress Thread
    private var progressThread: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.03))

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#A259FF").opacity(0.15),
                                Color(hex: "#A259FF").opacity(0.55),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * vm.progressFraction)
                    .animation(.linear(duration: 1), value: vm.progressFraction)
            }
        }
        .frame(height: 1)
    }

    // MARK: - Status Bar
    private var statusBar: some View {
        HStack {
            Text(formattedCurrentTime)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.25))
            Spacer()
        }
        .padding(.horizontal, 28)
        .padding(.top, 14)
    }

    private var formattedCurrentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    // MARK: - Task Identity
    private var taskIdentity: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "#A259FF"))
                    .frame(width: 5, height: 5)
                    .shadow(color: Color(hex: "#A259FF").opacity(0.7), radius: 5)
                    .scaleEffect(accentDotScale)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: accentDotScale
                    )
                    .onAppear { accentDotScale = 1.3 }

                Text(vm.routineName.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .tracking(1.8)
                    .foregroundColor(FormaTheme.Palette.textMuted)
            }
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: -4) {
                    Text(vm.taskLine1)
                        .font(.system(size: 38, weight: .light))
                        .foregroundColor(FormaTheme.Palette.textPrimary)
                        .tracking(-1)

                    if !vm.taskLine2.isEmpty {
                        Text(vm.taskLine2)
                            .font(.system(size: 38, weight: .light))
                            .foregroundColor(FormaTheme.Palette.textPrimary)
                            .tracking(-1)
                    }
            }
            .padding(.bottom, 7)

            if let description = vm.task.taskDescription, !description.isEmpty {
                Text("\"\(description)\"")
                    .font(.system(size: 14, weight: .light))
                    .italic()
                    .foregroundColor(Color(hex: "#A259FF").opacity(0.50))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, 16)
    }

    // MARK: - Timer Section
    private var timerSection: some View {
        VStack(spacing: 3) {
            Text(vm.remainingFormatted)
                .font(.system(size: 66, weight: .ultraLight))
                .foregroundColor(FormaTheme.Palette.textPrimary)
                .tracking(-2.6)
                .monospacedDigit()
                .shadow(color: Color(hex: "#A259FF").opacity(0.18), radius: 60)

            Text("remaining")
                .font(.system(size: 10, weight: .medium))
                .tracking(3.5)
                .textCase(.uppercase)
                .foregroundColor(FormaTheme.Palette.textMuted)

            Text(vm.breatheCue)
                .font(.system(size: 13, weight: .light))
                .italic()
                .foregroundColor(Color(hex: "#48484A").opacity(0.9))
                .opacity(breatheCueOpacity)
                .padding(.top, 10)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 7).repeatForever(autoreverses: true)
                    ) {
                        breatheCueOpacity = 0.75
                    }
                }
        }
        .padding(.top, 28)
    }

    // MARK: - Step Away Button
    private var stepAwayButton: some View {
        VStack {
            Spacer()
            HStack {
                Button("Step away") { vm.showStepAway = true }
                    .font(.system(size: 11, weight: .medium))
                    .tracking(2.2)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#48484A").opacity(0.70))
                    .padding(.leading, 28)
                    .padding(.bottom, 44)
                Spacer()
            }
        }
    }

    // MARK: - Sound Menu Button
    private var soundMenuButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FocusSoundMenu(
                    activeSound: $vm.activeSound,
                    menuOpen: $vm.soundMenuOpen,
                    onAITap: { vm.showAIOverlay = true }
                )
                .padding(.trailing, 28)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Tap to Dismiss Menu
    @ViewBuilder
    private var tapToDismissMenu: some View {
        if vm.soundMenuOpen {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        vm.soundMenuOpen = false
                    }
                }
                .ignoresSafeArea()
                .zIndex(1)
        } else {
            EmptyView()
        }
    }

    // MARK: - AI Overlay
    @ViewBuilder
    private var aiOverlay: some View {
        if vm.showAIOverlay {
            FocusAIOverlay(
                taskTitle: vm.task.title,
                onClose: { vm.showAIOverlay = false }
            )
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.4), value: vm.showAIOverlay)
            .zIndex(10)
        }
    }
}

extension RoutineTask {
    var taskDescription: String? {
        description
    }
}

#Preview {
    NavigationStack {
        FocusModeView(
            task: RoutineTask(
                id: "1",
                title: "Code Review PR",
                startTime: "09:00",
                duration: 45,
                description: "Ship clean, help the team.",
                state: .inProgress,
                isBreak: false
            ),
            routineName: "Morning Block",
            profession: "Developer",
            onStepAway: { _ in }
        )
    }
}
