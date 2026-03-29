//
//  MismatchBannerView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct DurationMismatch {
    let tasksTotalFormatted: String   // e.g. "1h 45m"
    let routineWindowFormatted: String // e.g. "2h 00m"
    let delta: Int                    // seconds — positive = tasks too short, negative = too long

    var message: String {
        if delta > 0 {
            return "Tasks are \(format(delta)) short. Extend a task or move the end time to \(routineWindowFormatted)."
        } else {
            return "Tasks exceed the routine by \(format(-delta)). Shorten a task or move the end time to \(tasksTotalFormatted)."
        }
    }

    private func format(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 && m > 0 { return "\(h)h \(m)m" }
        if h > 0           { return "\(h)h" }
        if m > 0 && s > 0  { return "\(m)m \(s)s" }
        if m > 0           { return "\(m)m" }
        return "\(s)s"
    }
}

struct DurationMismatchBanner: View {
    let mismatch: DurationMismatch

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(.white.opacity(0.45))
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                // Pill row: tasks total  ←→  routine window
                HStack(spacing: 8) {
                    durationPill(label: "TASKS", value: mismatch.tasksTotalFormatted,
                                 highlight: mismatch.delta < 0)   // too long → tasks pill lit
                    Text("→")
                        .font(.system(size: 9, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.2))
                    durationPill(label: "WINDOW", value: mismatch.routineWindowFormatted,
                                 highlight: mismatch.delta > 0)   // too short → window pill lit
                }

                Text(mismatch.message)
                    .font(.system(size: 11, weight: .light))
                    .foregroundStyle(.white.opacity(0.38))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.white.opacity(0.09), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func durationPill(label: String, value: String, highlight: Bool) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .regular))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.2))
            Text(value)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(highlight ? .white.opacity(0.75) : .white.opacity(0.35))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(highlight ? 0.07 : 0.03))
        )
    }
}
