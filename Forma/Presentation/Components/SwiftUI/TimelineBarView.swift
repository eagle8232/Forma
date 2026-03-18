//
//  TimelineBarView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/15/26.
//

import SwiftUI

struct TimelineBarView: View {
    let tasks: [RoutineTask]
    let startRaw: String
    let endRaw: String
    let accent: Color
    let vm: RoutineDetailViewModel

    @State private var appeared = false

    // Layout constants
    private let chipSpacing:  CGFloat = 130
    private let leadingInset: CGFloat = 10
    private let trailingInset: CGFloat = 40
    private let stemHeight:   CGFloat = 12
    private let dotSize:      CGFloat = 6
    private let chipH:        CGFloat = 26
    private let trackY:       CGFloat = 60

    private var totalWidth: CGFloat {
        leadingInset + CGFloat(tasks.count) * chipSpacing + trailingInset
    }

    private func x(for index: Int) -> CGFloat {
        leadingInset + CGFloat(index) * chipSpacing + chipSpacing / 2
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack(alignment: .topLeading) {

                // Canvas size
                Color.clear
                    .frame(width: totalWidth, height: 130)

                // MARK: Track
                Capsule()
                    .fill(.white.opacity(0.06))
                    .frame(width: totalWidth - leadingInset, height: 1.5)
                    .offset(x: leadingInset / 2, y: trackY)

                // MARK: Accent fill — animates on appear
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [accent, accent.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: appeared ? totalWidth - leadingInset : 0,
                        height: 2.5
                    )
                    .offset(x: leadingInset / 2, y: trackY)
                    .animation(.easeInOut(duration: 1.8).delay(0.15), value: appeared)

                // MARK: Chips
                ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                    let cx    = x(for: index)
                    let above = index % 2 == 0

                    // Stem
                    Rectangle()
                        .fill(accent.opacity(0.25))
                        .frame(width: 1, height: stemHeight)
                        .offset(
                            x: cx,
                            y: above ? trackY - stemHeight : trackY + 1.5
                        )

                    // Track dot — larger, bolder
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.15))
                            .frame(width: dotSize + 4, height: dotSize + 4)
                        Circle()
                            .fill(accent)
                            .frame(width: dotSize, height: dotSize)
                    }
                    .offset(
                        x: cx - (dotSize + 4) / 2,
                        y: trackY - (dotSize + 4) / 2 + 0.75
                    )
                    .opacity(appeared ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.3).delay(0.2 + Double(index) * 0.06),
                        value: appeared
                    )

                    // Chip pill
                    ChipPill(title: task.title, accent: accent)
                        .offset(
                            x: cx,   // center on x via chip's own alignment
                            y: above
                                ? trackY - stemHeight - chipH - 4
                                : trackY + stemHeight + 4 + 1.5
                        )
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(
                            appeared ? 1 : 0.4,
                            anchor: UnitPoint(x: 0.5, y: above ? 1 : 0)
                        )
                        .animation(
                            .spring(response: 0.42, dampingFraction: 0.68)
                            .delay(0.22 + Double(index) * 0.06),
                            value: appeared
                        )

                    // Time — opposite side from chip
                    Text(vm.formatTime(task.startTime))
                        .font(.system(size: 9, weight: .light))
                        .tracking(1.2)
                        .foregroundStyle(accent.opacity(0.45))
                        .fixedSize()
                        .offset(
                            x: cx - 14,
                            y: above
                                ? trackY + stemHeight + 6
                                : trackY - stemHeight - 16
                        )
                        .opacity(appeared ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.3)
                            .delay(0.28 + Double(index) * 0.06),
                            value: appeared
                        )
                }
            }
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Chip Pill

struct ChipPill: View {
    let title: String
    let accent: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accent)
                .frame(width: 5, height: 5)

            Text(title)
                .font(.system(size: 10, weight: .regular))
                .tracking(0.3)
                .foregroundStyle(.white.opacity(0.82))
                .fixedSize()
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.white.opacity(0.05))
                .overlay(
                    Capsule()
                        .strokeBorder(accent.opacity(0.4), lineWidth: 0.75)
                )
        )
        .fixedSize()
        .transformEffect(.init(translationX: 0, y: 0))
        .alignmentGuide(.leading) { d in d[HorizontalAlignment.center] }
    }
}
