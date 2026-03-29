//
//  NowWorlkingOnView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct NowWorkingOnView: View {
    
    let task: RoutineTask
    let routineStart: String
    let routineEnd: String
    let now: Date
    
    @State private var animatedProgress: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -300
    
    // MARK: - Derived
    private var minutesRemaining: String {
        let nowInSeconds = DateManager.shared.convertToSeconds(date: now)
        let endInSeconds = DateManager.shared.convertToSeconds(string: taskEndDateString ?? "")
        let remaining    = max(endInSeconds - nowInSeconds, 0)
        
        return DateManager.shared.formatMinutes(Int(ceil(Double(remaining / 60))))
    }
    
    /// 0.0–1.0 — how far through this specific task we are right now
    private var taskProgress: CGFloat {
        let nowInSeconds = DateManager.shared.convertToSeconds(date: now)
        let startInSeconds = DateManager.shared.convertToSeconds(string: task.startTime)
        let endInSeconds = DateManager.shared.convertToSeconds(string: taskEndDateString)
        
        let total = endInSeconds - startInSeconds
        let elapsed = nowInSeconds - startInSeconds
        
        guard total > 0 else { return 0 }
        return CGFloat(min(max(Double(elapsed) / Double(total), 0), 1))
    }
    
    private var taskEndDateString: String? {
        let start = DateManager.shared.convertToSeconds(string: task.startTime)
        let end = start + CGFloat(task.duration * 60)
        return DateManager.shared.convertToDateString(end)
    }
    
    private var timeRange: String {
        guard let end = taskEndDateString else { return "" }
        return "\(task.startTime) – \(end)"
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.card)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.card)
                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                )
            
            shimmerView
            
            VStack(alignment: .leading, spacing: 0) {
                eyebrow
                taskName.padding(.top, 8)
                metaRow.padding(.top, 8)
                
                if let desc = task.description, !desc.isEmpty {
                    Text(desc)
                        .customFont(.bodySmall)
                        .foregroundStyle(AppColor.textTertiary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                }
                
                remainingRow.padding(.top, 14)
                progressBar.padding(.top, 8)
            }
            .padding(.horizontal, AppSpacing.panelH)
            .padding(.vertical, AppSpacing.panelV)
        }
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.82).delay(0.15)) {
                animatedProgress = taskProgress
            }
            startShimmer()
        }
        .onChange(of: taskProgress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Subviews

extension NowWorkingOnView {
    
    private var eyebrow: some View {
        Text("NOW WORKING ON")
            .customFont(.microTracked)
            .tracking(AppTracking.sectionLabel)
            .foregroundStyle(AppColor.textTertiary)
    }
    
    private var taskName: some View {
        Text(task.title)
            .customFont(.bodyMedium)
            .foregroundStyle(AppColor.textPrimary)
            .lineLimit(2)
    }
    
    private var metaRow: some View {
        HStack(spacing: 8) {
            Text(timeRange)
                .customFont(.caption)
                .tracking(AppTracking.time)
                .foregroundStyle(AppColor.accentPrimary.opacity(AppOpacity.accentIcon))
            
            Rectangle()
                .fill(AppColor.surfaceBorder)
                .frame(width: AppSize.hairline, height: 10)
            
            Text(task.durationText)
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textTertiary)
            
            Rectangle()
                .fill(AppColor.surfaceBorder)
                .frame(width: AppSize.hairline, height: 10)
        }
    }
    
    private var remainingRow: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(AppColor.accentPrimary.opacity(0.4))
                .frame(width: 2, height: 10)
            
            Text(minutesRemaining)
                .customFont(.caption)
                .tracking(AppTracking.body)
                .foregroundStyle(.white.opacity(0.55))
                .contentTransition(.numericText())
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColor.surfaceDivider)
                    .frame(height: 1.5)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColor.accentPrimary.opacity(0.85),
                                AppColor.accentSecondary.opacity(0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * animatedProgress, height: 1.5)
            }
        }
        .frame(height: 1.5)
    }
    
    private var shimmerView: some View {
        GeometryReader { _ in
            LinearGradient(
                colors: [
                    .clear,
                    .white.opacity(0.03),
                    .white.opacity(AppOpacity.shimmer),
                    .white.opacity(0.03),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 140)
            .offset(x: shimmerOffset)
        }
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card))
    }
    
    private func startShimmer() {
        shimmerOffset = -300
        withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
            shimmerOffset = 500
        }
    }
}
