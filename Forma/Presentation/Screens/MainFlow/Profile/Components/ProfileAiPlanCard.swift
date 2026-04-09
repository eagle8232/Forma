//
//  ProfileAiPlanCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

// MARK: - Forma AI Plan Card

struct ProfileAIPlanCard: View {

    var onTap: () -> Void = {}

    @State private var isAnimating = false

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Animated gradient border
                animatedBorder

                // Inner card
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppColor.accent.opacity(0.2),
                                        AppColor.accent.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppColor.accent.opacity(0.2), lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)

                        Text("✦")
                            .font(.system(size: 20))
                    }

                    // Info
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Forma AI".uppercased())
                            .font(AppFont.ui(9, weight: .regular))
                            .kerning(2.8)
                            .foregroundColor(AppColor.accent)

                        Text("Pro Plan · Active")
                            .font(AppFont.ui(15, weight: .semibold))
                            .foregroundColor(AppColor.textPrimary)

                        Text("Unlimited routines · AI insights · Priority support")
                            .font(AppFont.ui(11, weight: .light))
                            .foregroundColor(AppColor.textMuted)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(AppColor.textMuted)
                }
                .padding(AppSpacing.blockGap)
                .background(AppColor.surface1)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(1.5) // inset from border
            }
        }
        .buttonStyle(FormaRowButtonStyle())
        .padding(.horizontal, AppSpacing.blockGap)
        .onAppear { isAnimating = true }
    }

    // MARK: - Animated border

    private var animatedBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                AngularGradient(
                    gradient: Gradient(stops: [
                        .init(color: AppColor.accent.opacity(0.0), location: 0.0),
                        .init(color: AppColor.accent.opacity(0.7), location: 0.25),
                        .init(color: AppColor.accent.opacity(0.6), location: 0.55),
                        .init(color: AppColor.accent.opacity(0.0), location: 1.0),
                    ]),
                    center: .center,
                    startAngle: .degrees(isAnimating ? 360 : 0),
                    endAngle: .degrees(isAnimating ? 720 : 360)
                )
            )
            .animation(
                .linear(duration: 5).repeatForever(autoreverses: false),
                value: isAnimating
            )
    }
}
