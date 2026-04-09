//
//  ProfileStatsView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

struct ProfileStatsView: View {

    @ObservedObject var viewModel: ProfileViewModel
    @State private var displayCompleted: Int = 0
    @State private var displayTotal: Int = 0

    var body: some View {
        VStack(spacing: AppSpacing.tightGap) {
            todayProgressCard
            
            weekChart
        }
        .padding(.horizontal, AppSpacing.blockGap)
        .onAppear {
            displayCompleted = viewModel.todayCompletedRoutines
            displayTotal = viewModel.totalRoutines
        }
        .onChange(of: viewModel.todayCompletedRoutines) { _, newValue in
            displayCompleted = newValue
        }
        .onChange(of: viewModel.totalRoutines) { _, newValue in
            displayTotal = newValue
        }
    }
    
    // MARK: - Today's Progress Card
    
    private var todayProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Progress")
                        .font(AppFont.display(22))
                        .foregroundColor(AppColor.textPrimary)
                    
                    Text("Keep up the momentum")
                        .font(AppFont.ui(11, weight: .regular))
                        .foregroundColor(AppColor.textMuted)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AppColor.surface2, lineWidth: 4)
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .trim(from: 0, to: displayTotal > 0 ? CGFloat(displayCompleted) / CGFloat(displayTotal) : 0)
                        .stroke(
                            AppColor.accent,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 56, height: 56)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(displayCompleted)/\(displayTotal)")
                        .font(AppFont.ui(12, weight: .semibold))
                        .foregroundColor(AppColor.textPrimary)
                }
            }
            
            HStack(spacing: 12) {
                progressStat(icon: "clock.fill", value: String(format: "%.1fh", viewModel.monthlyHours / 4), label: "This week")
                Spacer()
                progressStat(icon: "flame.fill", value: "\(viewModel.streak)", label: "Day streak")
            }
        }
        .padding(20)
        .background(AppColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
    
    private func progressStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColor.accent)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(AppFont.ui(14, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                
                Text(label)
                    .font(AppFont.ui(10, weight: .regular))
                    .foregroundColor(AppColor.textMuted)
            }
        }
    }

    // MARK: - Week chart

    private var weekChart: some View {
        HStack(spacing: 0) {
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

            HStack(alignment: .bottom, spacing: 5) {
                ForEach(viewModel.weeklyData) { item in
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
        case .today:    return AppColor.accent
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
