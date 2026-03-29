//
//  StrekView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

// MARK: - StreakView

struct StreakView: View {

    let data:   StreakData
    let accent: Color

    @State private var messageIndex: Int = 0
    @State private var messageOpacity: Double = 1
    @State private var shimmerOffset: CGFloat = -200
    @State private var appeared = false

    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    private var messages: [String] {
        [
            "\(data.currentStreak) day streak — keep the momentum.",
            "\(Int((Double(data.currentStreak) / Double(max(data.bestStreak, 1))) * 100))% of the way to your best.",
            "\(Int(data.completionRate * 100))% completion rate this month."
        ]
    }

    var body: some View {
        ZStack {
            // ── Glass background ──
            RoundedRectangle(cornerRadius: AppRadius.cardLg)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.cardLg)
                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                )

            // ── Content ──
            VStack(alignment: .leading, spacing: 0) {
                topRow
                    .padding(.bottom, 18)

                dayBars
                    .padding(.bottom, 14)

                Rectangle()
                    .fill(AppColor.surfaceDivider)
                    .frame(height: AppSize.hairline)
                    .padding(.bottom, 12)

                statsRow
                    .padding(.bottom, 12)

                rotatingMessage
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLg))
        .onReceive(timer) { _ in cycleMessage() }
        .padding(.horizontal, AppSpacing.screenH)
    }
}

// MARK: - Top Row

extension StreakView {

    private var topRow: some View {
        HStack(alignment: .top) {

            // Current streak
            VStack(alignment: .leading, spacing: 6) {
                Text("CURRENT STREAK")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textTertiary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(data.currentStreak)")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundStyle(AppColor.textPrimary)
                        .contentTransition(.numericText())

                    Text("days")
                        .customFont(.bodySmall)
                        .foregroundStyle(AppColor.textTertiary)
                }
            }

            Spacer()

            // Best streak pill
            VStack(alignment: .trailing, spacing: 6) {
                Text("BEST")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textTertiary)

                Text("\(data.bestStreak) days")
                    .customFont(.microTracked)
                    .tracking(AppTracking.body)
                    .foregroundStyle(accent.opacity(0.65))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.tag)
                            .fill(accent.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.tag)
                                    .stroke(accent.opacity(0.18), lineWidth: AppSize.hairline)
                            )
                    )
            }
            .padding(.top, 2)
        }
    }
}

// MARK: - Day Bars

extension StreakView {

    private var dayBars: some View {
        HStack(alignment: .bottom, spacing: 5) {
            ForEach(Array(data.weekDays.enumerated()), id: \.offset) { i, day in
                dayBar(day, index: i)
            }
        }
        .frame(height: 52)
    }

    private func dayBar(_ day: StreakData.DayEntry, index: Int) -> some View {
        let maxBarH: CGFloat = 36
        let barH: CGFloat    = day.state == .future
                               ? 4
                               : max(CGFloat(day.completion) * maxBarH, 4)

        let barColor: Color = {
            switch day.state {
            case .completed: return accent.opacity(0.4 + day.completion * 0.45)
            case .today:     return accent.opacity(0.9)
            case .partial:   return accent.opacity(0.3)
            case .missed:    return .clear
            case .future:    return .white.opacity(0.07)
            }
        }()

        let isToday = day.state == .today

        return VStack(spacing: 5) {
            Spacer()

            ZStack {
                if day.state == .missed {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(.white.opacity(0.1), lineWidth: AppSize.hairline)
                        .frame(height: 4)
                } else {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(height: appeared ? barH : 2)
                        .animation(
                            .easeOut(duration: 0.5).delay(Double(index) * 0.05),
                            value: appeared
                        )
                }
            }
            .frame(height: maxBarH, alignment: .bottom)

            Text(day.label)
                .font(.system(size: 8, weight: .light))
                .tracking(0.5)
                .foregroundStyle(
                    isToday
                    ? accent.opacity(0.7)
                    : AppColor.textTertiary
                )
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Row

extension StreakView {

    private var statsRow: some View {
        HStack {
            statItem(value: "\(data.totalDays)", label: "TOTAL DAYS")
            statDivider
            statItem(value: "\(Int(data.completionRate * 100))%", label: "COMPLETION")
            statDivider
            statItem(value: "\(data.thisWeekCompleted)/7", label: "THIS WEEK")
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .center, spacing: 3) {
            Text(value)
                .font(.system(size: 15, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.7))
                .contentTransition(.numericText())

            Text(label)
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(AppColor.surfaceDivider)
            .frame(width: AppSize.hairline, height: 28)
    }
}

// MARK: - Rotating Message

extension StreakView {

    private var rotatingMessage: some View {
        Text(messages[messageIndex])
            .customFont(.microTracked)
            .tracking(AppTracking.body)
            .foregroundStyle(AppColor.textTertiary)
            .lineSpacing(4)
            .opacity(messageOpacity)
            .animation(.easeInOut(duration: 0.3), value: messageOpacity)
    }

    private func cycleMessage() {
        withAnimation { messageOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            messageIndex = (messageIndex + 1) % messages.count
            withAnimation { messageOpacity = 1 }
        }
    }
}

