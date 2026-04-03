//
//  ProfileHeroView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

// MARK: - Hero Section

struct ProfileHeroView: View {
    let viewModel: ProfileViewModel

    @State private var ringAngle: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Avatar + name
            HStack(alignment: .bottom, spacing: 20) {
                avatarView
                nameBlock
            }
            .padding(.bottom, 24)

            // Score strip
            scoreStrip
        }
        .padding(.horizontal, AppSpacing.sectionGap)
        .padding(.top, AppSpacing.sectionGap)
    }

    // MARK: - Avatar

    private var avatarView: some View {
        ZStack {
            // Spinning arc ring
            Circle()
                .trim(from: 0.0, to: 0.18)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            AppColor.gold.opacity(0),
                            AppColor.gold.opacity(0.8),
                            AppColor.gold.opacity(0)
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 78, height: 78)
                .rotationEffect(.degrees(ringAngle))
                .onAppear {
                    withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                        ringAngle = 360
                    }
                }

            // Avatar circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.surface2, AppColor.surface3],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Circle().stroke(AppColor.border2, lineWidth: 1))
                    .frame(width: 72, height: 72)

                if viewModel.isAnonymous {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(AppColor.textMuted)
                } else {
                    // Initials
                    Text(initials)
                        .font(AppFont.display(24))
                        .foregroundColor(AppColor.textPrimary)
                }
            }

            // Online badge
            Circle()
                .fill(AppColor.green)
                .frame(width: 13, height: 13)
                .overlay(Circle().stroke(AppColor.background, lineWidth: 2))
                .offset(x: 24, y: 24)
        }
        .frame(width: 78, height: 78)
    }

    // MARK: - Name block

    private var nameBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Two-line name in display font
            VStack(alignment: .leading, spacing: -4) {
                Text(viewModel.firstName)
                    .font(AppFont.display(32))
                    .foregroundColor(AppColor.textPrimary)
                if !viewModel.lastName.isEmpty {
                    Text(viewModel.lastName)
                        .font(AppFont.display(32))
                        .foregroundColor(AppColor.textPrimary)
                }
            }

            if !viewModel.isAnonymous {
                Text("· \(viewModel.location)")
                    .font(AppFont.ui(11, weight: .light))
                    .foregroundColor(AppColor.textMuted)
            }

            Text(viewModel.profession)
                .font(AppFont.ui(11, weight: .light))
                .foregroundColor(AppColor.textMuted)
        }
        .padding(.bottom, 4)
    }

    // MARK: - Score strip

    private var scoreStrip: some View {
        HStack(spacing: 0) {
            Text("Today's score".uppercased())
                .font(AppFont.ui(10, weight: .regular))
                .kerning(2.2)
                .foregroundColor(AppColor.textMuted)

            Spacer()

            // Score value
            Text("87")
                .font(AppFont.display(22))
                .foregroundColor(AppColor.gold)

            Rectangle()
                .fill(AppColor.border)
                .frame(width: 1, height: 20)
                .padding(.horizontal, 14)

            // Streak
            HStack(spacing: 5) {
                Text("🔥")
                    .font(.system(size: 14))
                Text("12")
                    .font(AppFont.ui(13, weight: .semibold))
                    .foregroundColor(AppColor.textPrimary)
                Text("day streak")
                    .font(AppFont.ui(10, weight: .light))
                    .foregroundColor(AppColor.textMuted)
            }
        }
        .padding(.horizontal, AppSpacing.blockGap)
        .padding(.vertical, 12)
        .background(AppColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private var initials: String {
        let parts = viewModel.displayName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}
