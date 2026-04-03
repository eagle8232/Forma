//
//  GoalsListView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct GoalsListView: View {
    weak var coordinator: GoalsListCoordinator?
    var onAddGoal:    (() -> Void)? = nil

    @StateObject private var vm = GoalsViewModel()
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            GrainOverlay().ignoresSafeArea().allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    navBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    if vm.activeGoals.isEmpty && vm.achievedGoals.isEmpty {
                        emptyState
                            .padding(.top, 80)
                    } else {
                        content
                    }

                    Spacer().frame(height: AppSpacing.screenBottom)
                }
            }
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("GOALS")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textPrimary)

                Text("My Goals")
                    .customFont(.displaySmall)
                    .tracking(AppTracking.display)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer()

            Button(action: { onAddGoal?() }) {
                IconCircleButton(
                    icon: "plus",
                    iconSize: 13,
                    foregroundColor: .white.opacity(0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Active goals ──
            if !vm.activeGoals.isEmpty {
                sectionLabel("ACTIVE", count: vm.activeGoals.count)
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                    .padding(.bottom, 12)
                    .staggered(appeared, delay: 0.1)

                VStack(spacing: 10) {
                    ForEach(Array(vm.activeGoals.enumerated()), id: \.element.id) { i, goal in
                        GoalCard(goal: goal, onTap: { coordinator?.showGoalDetails(goal) })
                            .padding(.horizontal, 20)
                            .staggered(appeared, delay: 0.12 + Double(i) * 0.06)
                    }
                }
            }

            // ── Achieved ──
            if !vm.achievedGoals.isEmpty {
                sectionLabel("ACHIEVED", count: vm.achievedGoals.count)
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 12)
                    .staggered(appeared, delay: 0.28)

                VStack(spacing: 8) {
                    ForEach(vm.achievedGoals) { goal in
                        achievedRow(goal)
                            .padding(.horizontal, 20)
                    }
                }
                .staggered(appeared, delay: 0.32)
            }
        }
    }

    // MARK: - Section label

    private func sectionLabel(_ text: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textPrimary)

            Text("\(count)")
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(AppColor.textPrimary.opacity(0.5))
        }
    }

    // MARK: - Achieved row

    private func achievedRow(_ goal: Goal) -> some View {
        Button(action: { coordinator?.showGoalDetails(goal)}) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColor.surfaceFill)
                        .overlay(
                            Circle()
                                .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                        )
                        .frame(width: 28, height: 28)

                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(0.25))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(goal.title)
                        .customFont(.label)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(achievedDateString(goal))
                        .customFont(.caption)
                        .tracking(AppTracking.body)
                        .foregroundStyle(AppColor.textPrimary.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.15))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(AppColor.surfaceFill.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .stroke(AppColor.surfaceBorder.opacity(0.5), lineWidth: AppSize.hairline)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func achievedDateString(_ goal: Goal) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return "Completed \(f.string(from: goal.startDate))"
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColor.surfaceFill)
                    .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                    .frame(width: 56, height: 56)

                Image(systemName: "target")
                    .font(.system(size: 20, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.3))
            }

            VStack(spacing: 6) {
                Text("No goals yet")
                    .customFont(.heading2)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Tap + to create your first goal")
                    .customFont(.bodySmall)
                    .foregroundStyle(AppColor.textTertiary)
            }

            Button(action: { onAddGoal?() }) {
                Text("Create a goal")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.accentPrimary.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(AppColor.accentPrimary.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .stroke(AppColor.accentPrimary.opacity(0.2), lineWidth: AppSize.hairline)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stagger modifier

private extension View {
    func staggered(_ appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.45).delay(delay), value: appeared)
    }
}
