//
//  StatsView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/3/26.
//

import SwiftUI

struct StatsView: View {
    
    @StateObject private var viewModel = StatsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    streakCard
                    
                    todayStats
                    
                    periodSelector
                    
                    periodStats
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColor.textMuted)
                            .padding(10)
                            .background(AppColor.surface1)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .onAppear {
            viewModel.loadStats()
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Progress")
                .font(AppFont.display(28))
                .foregroundColor(AppColor.textPrimary)
            
            Text("Track your routine completion and streaks")
                .font(AppFont.ui(14, weight: .regular))
                .foregroundColor(AppColor.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Streak Card
    
    private var streakCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [AppColor.accentPrimary.opacity(0.2), AppColor.accentPrimary.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColor.accentPrimary.opacity(0.3), lineWidth: 1)
                )
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT STREAK")
                        .font(AppFont.ui(10, weight: .medium))
                        .kerning(2)
                        .foregroundColor(AppColor.textMuted)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(viewModel.streak)")
                            .font(AppFont.display(56))
                            .foregroundColor(AppColor.accentPrimary)
                        
                        Text(viewModel.streak == 1 ? "day" : "days")
                            .font(AppFont.ui(16, weight: .medium))
                            .foregroundColor(AppColor.textMuted)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                        
                        Text("Keep it up!")
                            .font(AppFont.ui(12, weight: .medium))
                            .foregroundColor(AppColor.textMuted)
                    }
                    
                    if viewModel.streak > 0 {
                        Text("Best: \(viewModel.bestStreak) days")
                            .font(AppFont.ui(11, weight: .regular))
                            .foregroundColor(AppColor.textMuted.opacity(0.7))
                    }
                }
            }
            .padding(24)
        }
        .frame(height: 140)
    }
    
    // MARK: - Today Stats
    
    private var todayStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TODAY")
                .font(AppFont.ui(10, weight: .medium))
                .kerning(2)
                .foregroundColor(AppColor.textMuted)
            
            HStack(spacing: 12) {
                statItem(
                    icon: "📊",
                    value: "\(viewModel.todayScore)",
                    unit: "%",
                    label: "Score"
                )
                
                statItem(
                    icon: "⏱",
                    value: String(format: "%.1f", viewModel.todayHours),
                    unit: "h",
                    label: "Hours"
                )
                
                statItem(
                    icon: "✅",
                    value: "\(viewModel.todayCompletedTasks)",
                    unit: "",
                    label: "Tasks"
                )
            }
        }
    }
    
    // MARK: - Period Selector
    
    private var periodSelector: some View {
        HStack(spacing: 0) {
            ForEach(StatsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedPeriod = period
                    }
                } label: {
                    Text(period.rawValue)
                        .font(AppFont.ui(13, weight: .medium))
                        .foregroundColor(
                            viewModel.selectedPeriod == period
                            ? AppColor.textPrimary
                            : AppColor.textMuted
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedPeriod == period
                            ? AppColor.surface2
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppColor.surface1)
        .clipShape(Capsule())
    }
    
    // MARK: - Period Stats
    
    private var periodStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.selectedPeriod.rawValue.uppercased())
                .font(AppFont.ui(10, weight: .medium))
                .kerning(2)
                .foregroundColor(AppColor.textMuted)
            
            VStack(spacing: 12) {
                statRow(label: "Average Score", value: "\(viewModel.periodStats.score)%")
                divider
                statRow(label: "Total Hours", value: String(format: "%.1f hours", viewModel.periodStats.hours))
                divider
                statRow(label: "Completed Routines", value: "\(viewModel.periodStats.completedRoutines)")
                divider
                statRow(label: "Completion Rate", value: viewModel.completionRate)
            }
            .padding(16)
            .background(AppColor.surface1)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColor.border, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    
    private func statItem(icon: String, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 20))
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppFont.display(24))
                    .foregroundColor(AppColor.textPrimary)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(AppFont.ui(12, weight: .medium))
                        .foregroundColor(AppColor.textMuted)
                }
            }
            
            Text(label)
                .font(AppFont.ui(10, weight: .medium))
                .kerning(1)
                .foregroundColor(AppColor.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppFont.ui(14, weight: .regular))
                .foregroundColor(AppColor.textMuted)
            
            Spacer()
            
            Text(value)
                .font(AppFont.ui(14, weight: .semibold))
                .foregroundColor(AppColor.textPrimary)
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(height: 1)
    }
}

// MARK: - ViewModel

enum StatsPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

@MainActor
final class StatsViewModel: ObservableObject {
    
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var todayScore: Int = 0
    @Published var todayHours: Double = 0
    @Published var todayCompletedTasks: Int = 0
    @Published var selectedPeriod: StatsPeriod = .week {
        didSet { updatePeriodStats() }
    }
    @Published var periodStats: (score: Int, hours: Double, completedRoutines: Int) = (0, 0, 0)
    
    var completionRate: String {
        guard periodStats.completedRoutines > 0 else { return "0%" }
        let totalRoutines = DependencyContainer.shared.routines?.count ?? 0
        guard totalRoutines > 0 else { return "0%" }
        let rate = Double(periodStats.completedRoutines) / Double(totalRoutines) * 100
        return "\(Int(rate))%"
    }
    
    func loadStats() {
        streak = CompletionService.shared.getStreak()
        todayScore = CompletionService.shared.getTodayScore()
        todayHours = CompletionService.shared.getTodayHours()
        
        let todayStats = CompletionService.shared.getStats(for: Date())
        todayCompletedTasks = todayStats.completedTasks
        
        bestStreak = max(streak, bestStreak)
        
        updatePeriodStats()
    }
    
    private func updatePeriodStats() {
        switch selectedPeriod {
        case .week:
            periodStats = CompletionService.shared.getWeeklyStats()
        case .month:
            periodStats = CompletionService.shared.getMonthlyStats()
        case .year:
            periodStats = CompletionService.shared.getYearStats()
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
