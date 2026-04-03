//
//  AIQuestionRenderer.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/29/26.
//

import SwiftUI

// MARK: - AIQuestionRenderer
// Takes an AIQuestion and renders the correct SwiftUI control.
// Completely decoupled from where it's used — works in onboarding, genie, chat.

struct AIQuestionRenderer: View {

    let question: AIQuestion
    @Binding var answer: AIAnswer
    var index:    Int   = 0
    var accent:   Color = AppColor.accentPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ── Question text + index ──
            questionHeader

            // ── Options — layout depends on type ──
            switch question.type {
            case .yesNo:
                yesNoRow

            case .singleChoice:
                if question.options.count <= 3 {
                    pillRow            // horizontal pills for short lists
                } else {
                    optionList         // vertical list for longer lists
                }

            case .multiChoice:
                optionList             // always vertical for multi-select
            }
        }
    }

    // MARK: - Header

    private var questionHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(String(format: "%02d", index))
                .font(.system(size: 9, weight: .ultraLight))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.15))

            Text(question.text)
                .customFont(.bodySmall)
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }

    // MARK: - Yes / No

    private var yesNoRow: some View {
        HStack(spacing: 8) {
            ForEach(question.options) { option in
                optionPill(option)
            }
            Spacer()
        }
    }

    // MARK: - Pill row (≤3 options)

    private var pillRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(question.options) { option in
                    optionPill(option)
                }
            }
        }
    }

    // MARK: - Vertical list (>3 options or multi-select)

    private var optionList: some View {
        VStack(spacing: 6) {
            ForEach(question.options) { option in
                optionRow(option)
            }
        }
    }

    // MARK: - Option pill (compact)

    private func optionPill(_ option: AIQuestionOption) -> some View {
        let selected = isSelected(option)

        return Button(action: { toggle(option) }) {
            HStack(spacing: 5) {
                if let emoji = option.emoji {
                    Text(emoji)
                        .font(.system(size: 12))
                }
                Text(option.label)
                    .customFont(.microTracked)
                    .tracking(AppTracking.body)
                    .foregroundStyle(
                        selected
                        ? accent.opacity(0.9)
                        : .white.opacity(0.38)
                    )
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selected ? accent.opacity(0.1) : .white.opacity(0.04))
                    .overlay(
                        Capsule()
                            .stroke(
                                selected ? accent.opacity(0.35) : .white.opacity(0.07),
                                lineWidth: AppSize.hairline
                            )
                    )
            )
            .animation(AppAnimation.springFast, value: selected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Option row (full width)

    private func optionRow(_ option: AIQuestionOption) -> some View {
        let selected = isSelected(option)

        return Button(action: { toggle(option) }) {
            HStack(spacing: 12) {
                if let emoji = option.emoji {
                    Text(emoji)
                        .font(.system(size: 14))
                }

                Text(option.label)
                    .customFont(.label)
                    .foregroundStyle(
                        selected
                        ? .white.opacity(0.85)
                        : .white.opacity(0.45)
                    )

                Spacer()

                // Checkmark indicator
                ZStack {
                    Circle()
                        .fill(selected ? accent.opacity(0.15) : .clear)
                        .overlay(
                            Circle()
                                .stroke(
                                    selected ? accent.opacity(0.5) : .white.opacity(0.1),
                                    lineWidth: AppSize.hairline
                                )
                        )
                        .frame(width: 18, height: 18)

                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .light))
                            .foregroundStyle(accent.opacity(0.85))
                    }
                }
                .animation(AppAnimation.springFast, value: selected)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(selected ? accent.opacity(0.07) : .white.opacity(0.025))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .stroke(
                                selected ? accent.opacity(0.25) : .white.opacity(0.06),
                                lineWidth: AppSize.hairline
                            )
                    )
            )
            .animation(AppAnimation.springFast, value: selected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Selection logic

    private func isSelected(_ option: AIQuestionOption) -> Bool {
        answer.selectedIds.contains(option.id)
    }

    private func toggle(_ option: AIQuestionOption) {
        switch question.type {
        case .singleChoice, .yesNo:
            // Replace selection
            answer = AIAnswer(
                questionId:     question.id,
                selectedIds:    [option.id],
                selectedLabels: [option.label]
            )

        case .multiChoice:
            // Toggle in/out
            var ids    = answer.selectedIds
            var labels = answer.selectedLabels
            if let i = ids.firstIndex(of: option.id) {
                ids.remove(at: i)
                labels.remove(at: i)
            } else {
                ids.append(option.id)
                labels.append(option.label)
            }
            answer = AIAnswer(
                questionId:     question.id,
                selectedIds:    ids,
                selectedLabels: labels
            )
        }
    }
}
