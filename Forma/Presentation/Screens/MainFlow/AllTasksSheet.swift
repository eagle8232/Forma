//
//  AllTasksSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/19/26.
//

import SwiftUI

struct AllTasksSheet: View {

    let routine:       RoutineBlock
    let tasks:         [RoutineTask]
    var onEditRoutine: (() -> Void)? = nil

    @StateObject private var vm: AllTasksViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        routine: RoutineBlock,
        tasks: [RoutineTask],
        onEditRoutine: (() -> Void)? = nil
    ) {
        self.routine       = routine
        self.tasks         = tasks
        self.onEditRoutine = onEditRoutine
        _vm = StateObject(wrappedValue: AllTasksViewModel(routine: routine, tasks: tasks))
    }

    var body: some View {
        ZStack {
            // ── Glassmorphic background ──
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Rectangle()
                .fill(.black.opacity(0.45))
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ──
                    header
                        .padding(.top, 8)
                        .padding(.horizontal, 22)

                    // ── Summary row ──
                    summaryRow
                        .padding(.top, 16)
                        .padding(.horizontal, 22)

                    // ── Sections ──
                    if !vm.activeTasks.isEmpty {
                        taskSection(label: "NOW", tasks: vm.activeTasks, style: .active)
                            .padding(.top, 20)
                    }

                    if !vm.upcomingTasks.isEmpty {
                        taskSection(label: "UPCOMING", tasks: vm.upcomingTasks, style: .upcoming)
                            .padding(.top, 16)
                    }

                    if !vm.completedTasks.isEmpty {
                        taskSection(label: "COMPLETED", tasks: vm.completedTasks, style: .completed)
                            .padding(.top, 16)
                    }

                    // ── Footer ──
                    if onEditRoutine != nil {
                        hairline.padding(.top, 20)
                        editRoutineButton.padding(.top, 4)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.ultraThinMaterial)
    }
}

// MARK: - Header

extension AllTasksSheet {

    private var header: some View {
        HStack {
            Text("ALL TASKS")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(AppColor.surfaceFill)
                        .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                        .frame(width: 26, height: 26)

                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .light))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Summary Row

extension AllTasksSheet {

    private var summaryRow: some View {
        HStack(spacing: 14) {

            // Mini progress ring
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.06), lineWidth: 1.5)

                Circle()
                    .trim(from: 0, to: vm.routineProgress)
                    .stroke(vm.accent, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(vm.routineProgress * 100))%")
                    .font(.system(size: 9, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .customFont(.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)

                Text(vm.routineSummary)
                    .customFont(.microTracked)
                    .tracking(AppTracking.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
            }

            Spacer()
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
}

// MARK: - Task Section

private enum RowStyle { case active, upcoming, completed }

extension AllTasksSheet {

    private func taskSection(
        label: String,
        tasks: [RoutineTask],
        style: RowStyle
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(label)
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { i, task in
                    taskRow(task: task, style: style)

                    if i < tasks.count - 1 {
                        Rectangle()
                            .fill(AppColor.surfaceDivider)
                            .frame(height: AppSize.hairline)
                            .padding(.leading, 44)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(AppColor.surfaceFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func taskRow(task: RoutineTask, style: RowStyle) -> some View {
        ZStack(alignment: .bottom) {

            // Active row accent background
            if style == .active {
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(vm.accent.opacity(0.07))
            }

            HStack(spacing: 12) {
                statusIndicator(style: style)

                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .customFont(.label)
                        .foregroundStyle(
                            style == .completed
                            ? AppColor.textDisabled
                            : AppColor.textPrimary
                        )
                        .strikethrough(style == .completed, color: .white.opacity(0.12))
                        .lineLimit(1)

                    Text(timeRange(for: task))
                        .customFont(.caption)
                        .tracking(AppTracking.body)
                        .foregroundStyle(
                            style == .completed
                            ? AppColor.textDisabled.opacity(0.6)
                            : AppColor.textPrimary
                        )
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    if style == .active {
                        Text("NOW")
                            .font(.system(size: 8, weight: .light))
                            .tracking(2)
                            .foregroundStyle(vm.accent.opacity(0.7))

                        Text("\(vm.minutesRemaining(for: task))m left")
                            .customFont(.microTracked)
                            .foregroundStyle(.white.opacity(0.28))
                    } else {
                        Text(task.durationText)
                            .customFont(.microTracked)
                            .tracking(AppTracking.microLabel)
                            .foregroundStyle(
                                style == .completed
                                ? AppColor.textDisabled
                                : vm.accent.opacity(AppOpacity.accentIcon)
                            )
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.tag)
                                    .fill(
                                        style == .completed
                                        ? .white.opacity(0.03)
                                        : vm.accent.opacity(AppOpacity.accentSubtle)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppRadius.tag)
                                            .stroke(
                                                style == .completed
                                                ? .white.opacity(0.06)
                                                : vm.accent.opacity(0.14),
                                                lineWidth: AppSize.hairline
                                            )
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)

            // Active task bottom progress bar
            if style == .active {
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [vm.accent.opacity(0.7), vm.accent.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * vm.taskProgress(for: task), height: 1.5)
                }
                .frame(height: 1.5)
            }
        }
    }

    @ViewBuilder
    private func statusIndicator(style: RowStyle) -> some View {
        ZStack {
            Circle()
                .stroke(
                    style == .active
                    ? vm.accent.opacity(0.7)
                    : style == .upcoming
                    ? vm.accent.opacity(0.28)
                    : .white.opacity(0.1),
                    lineWidth: AppSize.hairline
                )
                .background(
                    Circle().fill(
                        style == .active   ? vm.accent.opacity(0.1)  :
                        style == .completed ? .white.opacity(0.04)    : .clear
                    )
                )
                .frame(width: 20, height: 20)

            if style == .active {
                Circle()
                    .fill(vm.accent.opacity(0.85))
                    .frame(width: 6, height: 6)
            } else if style == .completed {
                Path { p in
                    p.move(to:    CGPoint(x: 5.5, y: 10))
                    p.addLine(to: CGPoint(x: 8.5, y: 13))
                    p.addLine(to: CGPoint(x: 14.5, y: 7))
                }
                .stroke(vm.accent.opacity(0.45), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .frame(width: 20, height: 20)
            }
        }
    }

    private func timeRange(for task: RoutineTask) -> String {
        let start = task.startTime
        let endSec = DateManager.shared.convertToSeconds(string: task.startTime) + CGFloat(task.duration * 60)
        let end = DateManager.shared.convertToDateString(endSec)
        return "\(start) – \(end)"
    }
}

// MARK: - Footer

extension AllTasksSheet {

    private var hairline: some View {
        Rectangle()
            .fill(AppColor.surfaceDivider)
            .frame(height: AppSize.hairline)
            .padding(.horizontal, 22)
    }

    private var editRoutineButton: some View {
        Button(action: {
            dismiss()
            onEditRoutine?()
        }) {
            Text("EDIT ROUTINE")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(.white.opacity(0.2))
                .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
