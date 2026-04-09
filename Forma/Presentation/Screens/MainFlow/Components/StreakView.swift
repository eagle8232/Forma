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
        .surfaceCard()
        .onAppear { appeared = true }
        .onReceive(timer) { _ in cycleMessage() }
        .padding(.horizontal, AppSpacing.screenH)
    }
}

// MARK: - Top Row

extension StreakView {

    private var topRow: some View {
        HStack(alignment: .top) {

            VStack(alignment: .leading, spacing: 6) {
                Text("CURRENT STREAK")
                    .font(.system(size: 8, weight: .regular))
                    .tracking(2)
                    .foregroundStyle(AppColor.textTertiary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(data.currentStreak)")
                        .font(.system(size: 42, weight: .ultraLight))
                        .foregroundStyle(AppColor.textPrimary)
                        .contentTransition(.numericText())

                    Text("days")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AppColor.textTertiary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("BEST")
                    .font(.system(size: 8, weight: .regular))
                    .tracking(2)
                    .foregroundStyle(AppColor.textTertiary)

                Text("\(data.bestStreak) days")
                    .font(.system(size: 10, weight: .regular))
                    .tracking(1)
                    .foregroundStyle(accent.opacity(0.65))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(accent.opacity(0.08))
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
        
        var barH: CGFloat = CGFloat(day.completion) * maxBarH
        
        switch day.state {
        case .future:
            barH = 4
        case .missed:
            barH = 4
        case .completed:
            barH = max(barH, 8)
        case .today:
            barH = max(barH, 8)
        case .partial:
            barH = max(barH, 6)
        }

        let barColor: Color = {
            switch day.state {
            case .completed: return accent.opacity(0.4 + day.completion * 0.45)
            case .today:     return accent.opacity(0.9)
            case .partial:   return accent.opacity(0.3)
            case .missed:    return .clear
            case .future:    return Color.adaptiveWhiteOpacity(0.07, lightOpacity: 0.15)
            }
        }()

        let isToday = day.state == .today

        return VStack(spacing: 5) {
            Spacer()

            ZStack {
                if day.state == .missed {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.adaptiveWhiteOpacity(0.1, lightOpacity: 0.2), lineWidth: AppSize.hairline)
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
            statItem(value: "\(data.totalDays)", label: "TOTAL")
            statDivider
            statItem(value: "\(Int(data.completionRate * 100))%", label: "RATE")
            statDivider
            statItem(value: "\(data.thisWeekCompleted)/7", label: "WEEK")
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .ultraLight))
                .foregroundStyle(AppColor.textSecondary)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 8, weight: .regular))
                .tracking(1.5)
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
            .font(.system(size: 10, weight: .regular))
            .foregroundStyle(AppColor.textTertiary)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
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

