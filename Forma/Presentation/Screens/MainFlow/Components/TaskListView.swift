//
//  TaskListView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct TaskListView: View {
    let tasks: [RoutineTask]
    let accent: Color
    var onTaskTap: ((RoutineTask) -> Void)? = nil

    private var upcoming: [RoutineTask] {
        tasks.filter { $0.state == .upcoming }
    }

    private var completed: [RoutineTask] {
        tasks.filter { $0.state == .completed  }
    }

    var body: some View {
        VStack(spacing: AppSpacing.sectionGap) {
            if !upcoming.isEmpty {
                taskPanel(
                    label: "UPCOMING",
                    tasks: upcoming,
                    isCompleted: false
                )
            }

            if !completed.isEmpty {
                taskPanel(
                    label: "COMPLETED",
                    tasks: completed,
                    isCompleted: true
                )
            }
        }
    }

    // MARK: - Panel

    private func taskPanel(
        label: String,
        tasks: [RoutineTask],
        isCompleted: Bool
    ) -> some View {
        VStack(spacing: 0) {

            // Section header
            HStack {
                Text(label)
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textTertiary)
                Spacer()
                Text("\(tasks.count)")
                    .customFont(.microTracked)
                    .tracking(AppTracking.microLabel)
                    .foregroundStyle(AppColor.textDisabled)
            }
            .padding(.horizontal, AppSpacing.screenHWide)
            .padding(.bottom, 10)

            // Rows inside glass card
            VStack(spacing: 0) {
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    TaskListRow(task: task, accent: accent, isCompleted: isCompleted)
                        .contentShape(Rectangle())
                        .onTapGesture { onTaskTap?(task) }

                    if index < tasks.count - 1 {
                        Rectangle()
                            .fill(AppColor.surfaceDivider)
                            .frame(height: AppSize.hairline)
                            .padding(.leading, 56)
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
}

// MARK: - TaskListRow

private struct TaskListRow: View {
    let task: RoutineTask
    let accent: Color
    let isCompleted: Bool

    @State private var appeared = false

    private var durationLabel: String {
        let h = task.duration / 60
        let m = task.duration % 60
        switch (h, m) {
        case (0, _): return "\(m)m"
        case (_, 0): return "\(h)h"
        default:     return "\(h)h \(m)m"
        }
    }

    var body: some View {
        HStack(spacing: 14) {

            // ── Status circle ──
            statusCircle

            // ── Task info ──
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .customFont(.label)
                    .foregroundStyle(
                        isCompleted
                        ? AppColor.textDisabled
                        : AppColor.textPrimary
                    )
                    .strikethrough(
                        isCompleted,
                        color: .white.opacity(0.15)
                    )
                    .lineLimit(1)

                Text(vm_timeRange)
                    .customFont(.caption)
                    .tracking(AppTracking.body)
                    .foregroundStyle(
                        isCompleted
                        ? AppColor.textMuted
                        : AppColor.textSecondary
                    )
            }

            Spacer()

            // ── Duration pill (upcoming only) ──
            if !isCompleted {
                Text(durationLabel)
                    .customFont(.caption)
                    .tracking(AppTracking.microLabel)
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.tag)
                            .fill(accent.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.tag)
                                    .stroke(accent.opacity(0.3), lineWidth: AppSize.hairline)
                            )
                    )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }

    private var statusCircle: some View {
        ZStack {
            Circle()
                .stroke(
                    isCompleted
                    ? accent.opacity(0.5)
                    : accent.opacity(0.7),
                    lineWidth: 1.5
                )
                .frame(width: 22, height: 22)
                .background(
                    Circle()
                        .fill(isCompleted ? accent.opacity(0.2) : .clear)
                )

            if isCompleted {
                Path { p in
                    p.move(to:    CGPoint(x: 6.5, y: 11))
                    p.addLine(to: CGPoint(x: 9.5, y: 14))
                    p.addLine(to: CGPoint(x: 15.5, y: 8))
                }
                .stroke(accent, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 22, height: 22)
            }
        }
    }

    private var vm_timeRange: String {
        let start = task.startTime
        guard
            let startDate = DateManager.shared.stringToDate(task.startTime)
        else { return start }
        let endDate = startDate.addingTimeInterval(TimeInterval(task.duration * 60))
        let end = DateManager.shared.dateToString(endDate)
        return "\(start) – \(end)"
    }
}

struct HomeActionButtons: View {
    var onAllTasks:      (() -> Void)? = nil
    var onRoutineDetail: (() -> Void)? = nil

    private let actions: [(icon: String, label: String, key: Int)] = [
        ("square.grid.2x2",         "All",    0),
        ("arrow.up.right.square",   "Routine",1)
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(actions, id: \.key) { action in
                ActionButton(
                    icon: action.icon,
                    label: action.label
                ) {
                    switch action.key {
                    case 0: onAllTasks?()
                    default: onRoutineDetail?()
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, AppSpacing.screenH)
    }
}

// MARK: - ActionButton

private struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var pressing = false
    
    private var iconColor: Color {
        Color.adaptive(dark: .white.opacity(pressing ? 0.6 : 0.38), light: Color.black.opacity(pressing ? 0.5 : 0.3))
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            pressing
                            ? AppColor.surfaceFillStrong
                            : AppColor.surfaceFill
                        )
                        .overlay(
                            Circle()
                                .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                        )
                        .frame(width: AppSize.stepperButton, height: AppSize.stepperButton)

                    Image(systemName: icon)
                        .font(.system(size: AppSize.iconMd, weight: .ultraLight))
                        .foregroundStyle(iconColor)
                }

                Text(label)
                    .customFont(.microTracked)
                    .tracking(AppTracking.microLabel)
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(pressing ? 0.94 : 1.0)
        .animation(AppAnimation.press, value: pressing)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressing = true }
                .onEnded   { _ in pressing = false }
        )
    }
}
