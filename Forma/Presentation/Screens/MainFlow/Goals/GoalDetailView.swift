//
//  GoalDetailView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct GoalDetailView: View {

    let goal:         Goal
    var onBack:       (() -> Void)? = nil
    var onRoutineTap: ((RoutineBlock) -> Void)? = nil
    var onDelete:     (() -> Void)? = nil

    @StateObject private var vm: GoalDetailViewModel
    @State private var appeared = false
    @State private var showDeleteAlert = false
    @State private var progressAnimated: Double = 0

    init(
        goal: Goal,
        onBack: (() -> Void)? = nil,
        onRoutineTap: ((RoutineBlock) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.goal         = goal
        self.onBack       = onBack
        self.onRoutineTap = onRoutineTap
        self.onDelete     = onDelete
        _vm = StateObject(wrappedValue: GoalDetailViewModel(goal: goal))
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            GrainOverlay().ignoresSafeArea().allowsHitTesting(false)
            ambientGlow.ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    navBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    heroSection
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .staggered(appeared, delay: 0.08)

                    progressSection
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .staggered(appeared, delay: 0.14)

                    statsGrid
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .staggered(appeared, delay: 0.20)

                    weekRow
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .staggered(appeared, delay: 0.26)

                    if vm.linkedRoutine != nil {
                        linkedRoutineSection
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .staggered(appeared, delay: 0.32)
                    }

                    deleteButton
                        .padding(.top, 32)
                        .staggered(appeared, delay: 0.38)

                    Spacer().frame(height: AppSpacing.screenBottom)
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
            withAnimation(.easeOut(duration: 0.9).delay(0.3)) {
                progressAnimated = goal.progress
            }
        }
        .alert("Delete goal", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                vm.delete { onDelete?() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove \"\(goal.title)\".")
        }
    }
}

// MARK: - Nav Bar

extension GoalDetailView {

    private var navBar: some View {
        HStack {
            Button(action: { onBack?() }) {
                IconCircleButton(icon: "chevron.left", iconSize: 12)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { showDeleteAlert = true }) {
                IconCircleButton(
                    icon: "ellipsis",
                    iconSize: 12,
                    foregroundColor: .white.opacity(0.35)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Hero Section

extension GoalDetailView {

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(vm.accent.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(vm.accent.opacity(0.2), lineWidth: AppSize.hairline)
                    )
                    .frame(width: 52, height: 52)

                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .ultraLight))
                    .foregroundStyle(vm.accent.opacity(0.8))
            }

            // Title
            Text(goal.title)
                .font(.system(size: 26, weight: .ultraLight))
                .foregroundStyle(AppColor.textPrimary)
                .tracking(-0.5)

            // Description
            if !goal.description.isEmpty {
                Text(goal.description)
                    .customFont(.bodySmall)
                    .foregroundStyle(AppColor.textTertiary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var iconName: String {
        let t = goal.title.lowercased()
        if t.contains("morning") { return "sun.horizon" }
        if t.contains("swift") || t.contains("code") || t.contains("learn") { return "chevron.left.forwardslash.chevron.right" }
        if t.contains("work") || t.contains("focus") { return "brain.head.profile" }
        if t.contains("read") || t.contains("book") { return "book" }
        if t.contains("workout") || t.contains("fitness") { return "figure.run" }
        return "target"
    }
}

// MARK: - Progress Section

extension GoalDetailView {

    private var progressSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text("\(Int(progressAnimated * 100))")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(vm.accent.opacity(0.9))
                    .monospacedDigit()
                    .contentTransition(.numericText())

                Text("%")
                    .font(.system(size: 18, weight: .ultraLight))
                    .foregroundStyle(AppColor.textTertiary)
                    .padding(.bottom, 6)

                Spacer()

                Text("COMPLETE")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textTertiary)
                    .padding(.bottom, 8)
            }
            .padding(.bottom, 10)

            // Track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(AppColor.surfaceDivider)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(vm.accent.opacity(0.6))
                        .frame(width: geo.size.width * progressAnimated, height: 3)
                }
            }
            .frame(height: 3)
            .padding(.bottom, 8)

            // Meta
            HStack {
                Text(vm.daysCompletedText)
                    .customFont(.microTracked)
                    .tracking(AppTracking.body)
                    .foregroundStyle(AppColor.textTertiary)

                Spacer()

                if let rem = vm.daysRemainingText {
                    Text(rem)
                        .customFont(.microTracked)
                        .tracking(AppTracking.body)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }
        }
    }
}

// MARK: - Stats Grid

extension GoalDetailView {

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 8
        ) {
            ForEach(vm.statsItems, id: \.0) { item in
                statCard(value: item.0, label: item.1)
            }
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.72))
                .monospacedDigit()

            Text(label.uppercased())
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                )
        )
    }
}

// MARK: - Week Row

extension GoalDetailView {

    private var weekRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("THIS WEEK")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textTertiary)

            HStack(spacing: 6) {
                ForEach(vm.weekEntries) { entry in
                    dayCell(entry)
                }
            }
        }
    }

    private func dayCell(_ entry: GoalDetailViewModel.WeekEntry) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(
                        entry.state == .completed
                        ? vm.accent.opacity(0.15)
                        : AppColor.surfaceFill
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                entry.state == .completed
                                ? vm.accent.opacity(entry.isToday ? 0.7 : 0.3)
                                : entry.isToday
                                ? vm.accent.opacity(0.3)
                                : AppColor.surfaceBorder,
                                lineWidth: AppSize.hairline
                            )
                    )
                    .frame(width: 36, height: 36)

                if entry.state == .completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .ultraLight))
                        .foregroundStyle(vm.accent.opacity(entry.isToday ? 0.9 : 0.6))
                } else if entry.state == .missed {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.15))
                }
            }

            Text(entry.label)
                .font(.system(size: 9, weight: .ultraLight))
                .tracking(0.5)
                .foregroundStyle(
                    entry.isToday
                    ? vm.accent.opacity(0.6)
                    : AppColor.textTertiary
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Linked Routine

extension GoalDetailView {

    private var linkedRoutineSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("LINKED ROUTINE")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textPrimary)

            if let routine = vm.linkedRoutine {
                Button(action: { onRoutineTap?(routine) }) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color(uiColor: UIColor(hex: routine.accentColor)).opacity(0.7))
                            .frame(width: 8, height: 8)

                        Text(routine.title)
                            .customFont(.label)
                            .foregroundStyle(.white.opacity(0.6))

                        Spacer()

                        Text("\(routine.startTime) – \(routine.endTime)")
                            .customFont(.caption)
                            .tracking(AppTracking.time)
                            .foregroundStyle(AppColor.textTertiary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .ultraLight))
                            .foregroundStyle(.white.opacity(0.15))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .fill(AppColor.surfaceFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.card)
                                    .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Delete Button

extension GoalDetailView {

    private var deleteButton: some View {
        Button(action: { showDeleteAlert = true }) {
            Text("Delete goal")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(.white.opacity(0.18))
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ambient glow

extension GoalDetailView {

    private var ambientGlow: some View {
        RadialGradient(
            colors: [vm.accent.opacity(0.07), .clear],
            center: .init(x: 0.5, y: 0.05),
            startRadius: 0,
            endRadius: 300
        )
    }
}

// MARK: - Stagger modifier

private extension View {
    func staggered(_ appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.45).delay(delay), value: appeared)
    }
}
