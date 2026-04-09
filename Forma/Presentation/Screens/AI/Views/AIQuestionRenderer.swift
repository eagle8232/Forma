//
//  AIQuestionRenderer.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/29/26.
//

import SwiftUI

struct AIQuestionRenderer: View {

    let question: AIQuestion
    @Binding var answer: AIAnswer
    var index:    Int   = 0
    var accent:   Color = AppColor.accentPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch question.type {
            case .yesNo:
                yesNoRow

            case .singleChoice:
                if question.options.count <= 3 {
                    pillRow
                } else {
                    optionList
                }

            case .multiChoice:
                optionList
            }
        }
    }

    // MARK: - Yes / No

    private var yesNoRow: some View {
        HStack(spacing: 10) {
            ForEach(question.options) { option in
                optionPill(option)
            }
            Spacer()
        }
    }

    // MARK: - Pill row (≤3 options)

    private var pillRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(question.options) { option in
                    optionPill(option)
                }
            }
        }
    }

    // MARK: - Vertical list (>3 options or multi-select)

    private var optionList: some View {
        VStack(spacing: 8) {
            ForEach(question.options) { option in
                optionRow(option)
            }
        }
    }

    // MARK: - Option pill (compact)

    private func optionPill(_ option: AIQuestionOption) -> some View {
        let selected = isSelected(option)

        return Button(action: { toggle(option) }) {
            HStack(spacing: 6) {
                if let emoji = option.emoji {
                    Text(emoji)
                        .font(.system(size: 13))
                }
                Text(option.label)
                    .font(.system(size: 11, weight: selected ? .medium : .ultraLight))
                    .tracking(1)
                    .foregroundStyle(
                        selected
                        ? .white.opacity(0.85)
                        : .white.opacity(0.35)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(selected ? .white.opacity(0.08) : .white.opacity(0.02))
            )
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Option row (full width)

    private func optionRow(_ option: AIQuestionOption) -> some View {
        let selected = isSelected(option)

        return Button(action: { toggle(option) }) {
            HStack(spacing: 14) {
                if let emoji = option.emoji {
                    Text(emoji)
                        .font(.system(size: 16))
                }

                Text(option.label)
                    .font(.system(size: 14, weight: selected ? .medium : .ultraLight))
                    .foregroundStyle(
                        selected
                        ? .white.opacity(0.85)
                        : .white.opacity(0.4)
                    )

                Spacer()

                if selected {
                    Circle()
                        .fill(.white.opacity(0.08))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                        )
                } else {
                    Circle()
                        .stroke(.white.opacity(0.08), lineWidth: 0.5)
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? .white.opacity(0.05) : .white.opacity(0.015))
            )
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: selected)
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
            answer = AIAnswer(
                questionId:     question.id,
                selectedIds:    [option.id],
                selectedLabels: [option.label]
            )

        case .multiChoice:
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
