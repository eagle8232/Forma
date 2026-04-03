//
//  GoalCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

// MARK: - GoalCard

struct GoalCard: View {

    let goal:   Goal
    var onTap:  (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    iconView
                    infoStack
                    rightStack
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

                progressBar
            }
        }
        .surfaceCard()
        .buttonStyle(CardButtonStyle())
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Icon

    private var iconView: some View {
        AccentIconBadge(
            icon: iconName,
            accent: goal.accent,
            backgroundOpacity: 0.1,
            borderOpacity: 0.2
        )
    }

    private var iconName: String {
        // Pick icon based on title keywords — fallback to target
        let t = goal.title.lowercased()
        if t.contains("morning") || t.contains("routine") { return "sun.horizon" }
        if t.contains("swift") || t.contains("code") || t.contains("learn") { return "chevron.left.forwardslash.chevron.right" }
        if t.contains("work") || t.contains("focus") { return "brain.head.profile" }
        if t.contains("read") || t.contains("book") { return "book" }
        if t.contains("workout") || t.contains("fitness") { return "figure.run" }
        return "target"
    }

    // MARK: - Info

    private var infoStack: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(goal.title)
                .customFont(.label)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            Text(goal.description)
                .customFont(.caption)
                .tracking(AppTracking.body)
                .foregroundStyle(AppColor.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Right

    private var rightStack: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("\(Int(goal.progress * 100))%")
                .font(.system(size: 14, weight: .ultraLight))
                .foregroundStyle(goal.accent.opacity(0.85))
                .monospacedDigit()

            if goal.streak > 0 {
                HStack(spacing: 3) {
                    Text("\(goal.streak)d")
                        .customFont(.microTracked)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("streak")
                        .customFont(.microTracked)
                        .foregroundStyle(AppColor.textPrimary.opacity(0.6))
                }
            }
        }
        .fixedSize()
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppColor.surfaceDivider)
                    .frame(height: 2)

                Rectangle()
                    .fill(goal.accent.opacity(0.55))
                    .frame(
                        width: appeared
                        ? geo.size.width * CGFloat(goal.progress)
                        : 0,
                        height: 2
                    )
                    .animation(.easeOut(duration: 0.7).delay(0.2), value: appeared)
            }
        }
        .frame(height: 2)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLg))
    }
}
