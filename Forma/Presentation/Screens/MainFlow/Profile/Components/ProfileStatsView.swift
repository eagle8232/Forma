//
//  ProfileStatsView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

// MARK: - Stats Section

struct ProfileStatsView: View {

    let viewModel: ProfileViewModel

    // Mock weekly data — replace with real RoutineStore data
    private let weekData: [WeekBarData] = [
        .init(day: "M", pct: 0.78, state: .done),
        .init(day: "T", pct: 0.94, state: .done),
        .init(day: "W", pct: 0.62, state: .done),
        .init(day: "T", pct: 0.88, state: .done),
        .init(day: "F", pct: 0.45, state: .today),
        .init(day: "S", pct: 0.0,  state: .upcoming),
        .init(day: "S", pct: 0.0,  state: .upcoming),
    ]

    var body: some View {
        VStack(spacing: AppSpacing.tightGap) {
            // 2-col grid
            HStack(spacing: AppSpacing.tightGap) {
                FormaStatCard(
                    icon: "✅",
                    value: "94",
                    unit: "%",
                    label: "Completion",
                    delta: "6% vs last week"
                )
                FormaStatCard(
                    icon: "⏱",
                    value: "38",
                    unit: "h",
                    label: "This month",
                    delta: "4h vs March"
                )
            }

            // Week bar chart — full width
            weekChart
        }
        .padding(.horizontal, AppSpacing.blockGap)
    }

    // MARK: - Week chart

    private var weekChart: some View {
        HStack(spacing: 0) {
            // Left label
            VStack(alignment: .leading, spacing: 0) {
                Text("📅")
                    .font(.system(size: 18))
                    .padding(.bottom, 12)
                Text("This Week")
                    .font(AppFont.display(22))
                    .foregroundColor(AppColor.textPrimary)
                Text("Daily completion".uppercased())
                    .font(AppFont.ui(10, weight: .regular))
                    .kerning(1.5)
                    .foregroundColor(AppColor.textMuted)
                    .padding(.top, 2)
            }
            .padding(AppSpacing.blockGap)

            Spacer()

            // Bar chart
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(weekData) { item in
                    weekBar(item)
                }
            }
            .frame(height: 56)
            .padding(.trailing, AppSpacing.blockGap)
            .padding(.bottom, AppSpacing.blockGap)
        }
        .background(AppColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func weekBar(_ data: WeekBarData) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(barColor(data.state))
                .frame(width: 20, height: max(6, 40 * data.pct))

            Text(data.day)
                .font(AppFont.ui(8, weight: .regular))
                .kerning(0.5)
                .foregroundColor(AppColor.textMuted)
        }
        .frame(maxHeight: 52, alignment: .bottom)
    }

    private func barColor(_ state: WeekBarData.State) -> Color {
        switch state {
        case .done:     return AppColor.accent
        case .today:    return AppColor.gold
        case .upcoming: return AppColor.surface3
        }
    }
}

// MARK: - Supporting model

struct WeekBarData: Identifiable {
    let id = UUID()
    let day: String
    let pct: Double
    let state: State

    enum State { case done, today, upcoming }
}
