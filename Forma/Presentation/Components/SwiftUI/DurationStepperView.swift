//
//  DurationStepperView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct DurationStepperView: View {
    let taskID: String
    let currentMinutes: Int
    let accent: Color
    let onCommit: (Int) -> Void

    @State private var draft: Int

    private let stepSmall = 5     // regular tap
    private let stepLarge = 15    // long-press
    private let minMinutes = 5
    private let maxMinutes = 480  // 8 hours cap

    init(taskID: String, currentMinutes: Int, accent: Color, onCommit: @escaping (Int) -> Void) {
        self.taskID        = taskID
        self.currentMinutes = currentMinutes
        self.accent        = accent
        self.onCommit      = onCommit
        _draft             = State(initialValue: currentMinutes)
    }

    var body: some View {
        HStack(spacing: 0) {

            StepButton(icon: "minus", accent: accent) {
                step(by: -stepSmall)
            } onLongPress: {
                step(by: -stepLarge)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(DurationFormatter.formatCompact(draft))
                    .font(.system(size: 18, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.88))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: draft)
                    .monospacedDigit()

                Text("DURATION")
                    .font(.system(size: 8, weight: .regular))
                    .tracking(2.5)
                    .foregroundStyle(.white.opacity(0.2))
            }
            .frame(minWidth: 90)

            Spacer()

            StepButton(icon: "plus", accent: accent) {
                step(by: stepSmall)
            } onLongPress: {
                step(by: stepLarge)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.07), lineWidth: 0.5)
                )
        )
    }

    private func step(by delta: Int) {
        let next = (draft + delta).clamped(to: minMinutes...maxMinutes)
        guard next != draft else { return }
        draft = next
        onCommit(next)
    }
}

private struct StepButton: View {
    let icon: String
    let accent: Color
    let onTap: () -> Void
    let onLongPress: () -> Void

    @State private var pressing = false

    var body: some View {
        Button(action: onTap) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .ultraLight))
                .foregroundStyle(accent.opacity(pressing ? 1.0 : 0.6))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(.white.opacity(pressing ? 0.08 : 0.0))
                )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onChanged { _ in pressing = true }
                .onEnded { _ in
                    pressing = false
                    onLongPress()
                }
        )
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
