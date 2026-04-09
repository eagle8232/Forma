//
//  HomeView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    @StateObject var vm: HomeViewModel
    var coordinator: HomeCoordinator

    @State private var appeared = false
    @State private var selectedIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showAllTasks: Bool = false
    @State private var showCompletionSheet: Bool = false
    @State private var completionRoutines: [RoutineBlock] = []

    init(routines: [RoutineBlock]? = nil, coordinator: HomeCoordinator) {
        self._vm = StateObject(wrappedValue: HomeViewModel(routines: routines))
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            switch vm.loadState {
            case .loading, .idle:
                loadingView
            case .error(let msg):
                errorView(msg)
            case .loaded:
                mainContent
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                dateHeader
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let user = vm.user {
                        coordinator.showProfileView(user: user)
                    }
                } label: {
                    IconCircleButton(
                        icon: "person.fill",
                        size: 36,
                        iconSize: 14,
                        foregroundColor: Color.adaptiveWhiteOpacity(0.5, lightOpacity: 0.4)
                    )
                }
                .buttonStyle(.plain)
            }
        })
        .sheet(isPresented: $showAllTasks) {
            if let routine = vm.activeRoutine {
                AllTasksSheet(
                    routine: routine,
                    tasks: vm.tasks,
                    onEditRoutine: {
                        coordinator.showRoutineDetails(routine)
                    }
                )
            }
        }
        .sheet(isPresented: $showCompletionSheet) {
            if !completionRoutines.isEmpty {
                RoutineCompletionSheet(
                    routines: completionRoutines,
                    onComplete: { routineId, taskStates in
                        CompletionService.shared.saveCompletion(
                            routineId: routineId,
                            completedTasks: taskStates
                        )
                        vm.markRoutineAsCompleted(routineId)
                    },
                    onDismiss: {
                        showCompletionSheet = false
                        vm.clearPendingRoutine()
                    }
                )
            }
        }
        .onChange(of: vm.shouldShowCompletionSheet) { _, newValue in
            if newValue {
                completionRoutines = vm.getPendingRoutines()
                print("[DEBUG] onChange: showing completion sheet, routines: \(completionRoutines.map { $0.title })")
                showCompletionSheet = true
            }
        }
        .onAppear {
            if vm.shouldShowCompletionSheet {
                completionRoutines = vm.getPendingRoutines()
                print("[DEBUG] onAppear: showing completion sheet, routines: \(completionRoutines.map { $0.title })")
                showCompletionSheet = true
            }
        }
        .onAppear {
            withAnimation { appeared = true }
            Task { await vm.load() }
            vm.startLiveTimer()
        }
        .onDisappear {
            vm.stopLiveTimer()
        }
    }

    // MARK: - Main content

    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                
                ringSection
                    .padding(.top, 16)

                // Routine status badge — only when routine is loaded
                if let routine = vm.activeRoutine {
                    routineStatusBadge(routine)
                        .padding(.top, 12)
                        .staggered(appeared, delay: 0.12)
                }

                // Page indicator — only when more than one routine
                if vm.routines.count > 1 {
                    pageIndicator
                        .padding(.top, 14)
                        .staggered(appeared, delay: 0.15)
                }

                timeStrip
                    .padding(.top, 22)
                    .padding(.horizontal, AppSpacing.screenHWide)
                    .staggered(appeared, delay: 0.18)

                if let currentTask = vm.currentTask {
                    NowWorkingOnView(
                        task: currentTask,
                        routineStart: vm.activeRoutine?.startTime ?? "",
                        routineEnd:   vm.activeRoutine?.endTime   ?? "",
                        now: vm.now,
                        onTap: {
                            if let routine = vm.activeRoutine, let user = vm.user {
                                coordinator.showFocusMode(task: currentTask, routine: routine, user: user)
                            }
                        }
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .staggered(appeared, delay: 0.24)
                }

                TaskListView(
                    tasks: vm.sortedTasks,
                    accent: vm.accent,
                    onTaskTap: { _ in }
                )
                .padding(.top, AppSpacing.sectionGap)
                .staggered(appeared, delay: 0.30)

                HomeActionButtons(
                    onAllTasks:      { showAllTasks = true },
                    onRoutineDetail: {
                        guard let r = vm.activeRoutine else { return }
                        coordinator.showRoutineDetails(r)
                    }
                )
                .padding(.top, 28)
                .staggered(appeared, delay: 0.36)
                
                Spacer().frame(height: AppSpacing.screenBottom)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            BreathingLineView()
                .frame(width: 24, height: 1)
            Text("LOADING")
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: AppSize.iconLg, weight: .ultraLight))
                .foregroundStyle(AppColor.errorText.opacity(0.6))

            Text(message)
                .customFont(.bodySmall)
                .foregroundStyle(AppColor.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.screenHWide)

            Button("Retry") { Task { await vm.load() } }
                .customFont(.caption)
                .foregroundStyle(AppColor.accentPrimary.opacity(AppOpacity.accentIcon))
        }
    }
}

// MARK: - Date Header

extension HomeView {

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(vm.weekdayLabel)
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textTertiary)

            Text(vm.dateLabel)
                .customFont(.displaySmall)
                .tracking(AppTracking.display)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
}

// MARK: - Ring Section (ZStack carousel — side rings visible)

extension HomeView {

    private var ringSection: some View {
        ZStack {

            // ── Single TabView — one full-size ring per page ──
            TabView(selection: $selectedIndex) {
                ForEach(Array(vm.routines.enumerated()), id: \.element.id) { index, routine in
                    let accent = Color(uiColor: UIColor(hex: routine.accentColor))

                    let isCompleted = vm.isRoutineCompleted(routine)
                    let isUpcoming  = vm.isRoutineUpcoming(routine)

                    let ringProgress: Double = isCompleted ? 1.0
                                             : isUpcoming  ? 0.0
                                             : vm.progressFor(routine)
                    let ringAccent: Color    = (isCompleted || isUpcoming)
                                             ? Color.adaptiveWhiteOpacity(0.5, lightOpacity: 0.4)
                                             : accent

                    CircleProgressView(
                        progress: ringProgress,
                        size: 220,
                        strokeWidth: 3.5,
                        accent: ringAccent
                    ) {
                        VStack(spacing: 3) {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("\(Int(ringProgress * 100))")
                                    .customFont(.displayThin)
                                    .tracking(AppTracking.display)
                                    .foregroundStyle(AppColor.textPrimary)
                                Text("%")
                                    .customFont(.heading2)
                                    .foregroundStyle(AppColor.textDisabled)
                            }
                            Text("complete")
                                .customFont(.microTracked)
                                .tracking(AppTracking.sectionLabel)
                                .foregroundStyle(AppColor.textTertiary)
                        }
                    }
                    .tag(index)
                    .padding(.vertical, 8)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 260)
            .onChange(of: selectedIndex) { _, newIndex in
                vm.selectRoutine(at: newIndex)
            }

            HStack(spacing: 0) {
                Group {
                    if selectedIndex > 0 {
                        arrowCircle(direction: .left) {
                            let next = max(selectedIndex - 1, 0)
                            guard next != selectedIndex else { return }
                            withAnimation(.easeInOut(duration: 0.28)) { selectedIndex = next }
                            vm.selectRoutine(at: next)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 64)

                Color.clear

                Group {
                    if selectedIndex >= 0 && selectedIndex < vm.routines.count - 1 {
                        arrowCircle(direction: .right) {
                            let next = min(selectedIndex + 1, vm.routines.count - 1)
                            guard next != selectedIndex else { return }
                            withAnimation(.easeInOut(duration: 0.28)) { selectedIndex = next }
                            vm.selectRoutine(at: next)
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        Color.clear
                    }
                }
                .frame(width: 64)
            }
            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
        }
        .frame(height: 260)
        .onChange(of: vm.activeRoutine?.id) { _, id in
            guard let id,
                  let i = vm.routines.firstIndex(where: { $0.id == id }),
                  i != selectedIndex
            else { return }
            withAnimation(.easeInOut(duration: 0.28)) { selectedIndex = i }
        }
        .onAppear {
            if let active = vm.activeRoutine,
               let i = vm.routines.firstIndex(where: { $0.id == active.id }) {
                selectedIndex = i
            }
        }
    }

    // MARK: - Arrow Capsule

    private enum ArrowDirection { case left, right }

    @ViewBuilder
    private func arrowCircle(direction: ArrowDirection, action: @escaping () -> Void) -> some View {
        Button {
            SoundManager.shared.playHaptic()
            action()
        } label: {
            Image(systemName: direction == .left ? "chevron.left" : "chevron.right")
                .font(.system(size: 11, weight: .ultraLight))
                .foregroundStyle(Color.adaptiveWhiteOpacity(0.4, lightOpacity: 0.35))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.adaptiveWhiteOpacity(0.055, lightOpacity: 0.08))
                        .overlay(
                            Circle()
                                .stroke(Color.adaptiveWhiteOpacity(0.09, lightOpacity: 0.15), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(vm.routines.indices, id: \.self) { i in
                let isSelected = i == selectedIndex
                let dotAccent  = Color(uiColor: UIColor(hex: vm.routines[i].accentColor))
                RoundedRectangle(cornerRadius: 2)
                    .fill(isSelected ? dotAccent.opacity(0.7) : AppColor.surfaceDivider)
                    .frame(width: isSelected ? 16 : 4, height: 2)
                    .animation(AppAnimation.spring, value: selectedIndex)
            }
        }
    }
    
    private func routineStatusBadge(_ routine: RoutineBlock) -> some View {
        HStack(spacing: 8) {
            StatusDot(isDone: vm.progress >= 1.0)
            
            Text(routine.title)
                .customFont(.caption)
                .tracking(AppTracking.bodyTight)
                .foregroundStyle(AppColor.textTertiary)
                .lineLimit(1)
            
            Text("•")
                .foregroundStyle(AppColor.textTertiary.opacity(0.5))
            
            Text(statusString)
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
    }
    
    private var statusString: String {
        guard let routine = vm.activeRoutine else { return "" }
        if vm.isRoutineCompleted(routine) { return "COMPLETED" }
        else if vm.isRoutineUpcoming(routine) { return "UPCOMING" }
        else { return "ACTIVE" }
    }
}

// MARK: - Time Strip

extension HomeView {

    private var timeStrip: some View {
        HStack(spacing: 0) {
            timeItem(label: "START", value: vm.formattedStartTime, isAccent: true)
            Spacer()
            stripSeparator
            Spacer()
            timeItem(label: "NOW",   value: vm.formattedNow,       isAccent: false)
            Spacer()
            stripSeparator
            Spacer()
            timeItem(label: "END",   value: vm.formattedEndTime,   isAccent: true)
        }
    }

    private func timeItem(label: String, value: String, isAccent: Bool) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textTertiary)
            Text(value)
                .customFont(.caption)
                .tracking(AppTracking.time)
                .foregroundStyle(
                    isAccent
                    ? vm.accent.opacity(AppOpacity.accentIcon)
                    : AppColor.textTertiary
                )
                .contentTransition(.numericText())
                .animation(AppAnimation.fadeSwap, value: vm.formattedNow)
        }
    }

    private var stripSeparator: some View {
        VStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(AppColor.surfaceDivider)
                    .frame(width: 2, height: 2)
            }
        }
        .padding(.top, 14)
    }
}

// MARK: - Background Glow

extension HomeView {

    private var backgroundGlow: some View {
        ZStack {
            RadialGradient(
                colors: [AppColor.accentPrimary.opacity(0.09), .clear],
                center: .init(x: 0.5, y: 0.18),
                startRadius: 0, endRadius: 280
            )
            RadialGradient(
                colors: [AppColor.accentPrimary.opacity(0.06), .clear],
                center: .init(x: 0.5, y: 1.1),
                startRadius: 0, endRadius: 300
            )
        }
    }
}

// MARK: - Stagger modifier

private extension View {
    func staggered(_ appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(delay), value: appeared)
    }
}
