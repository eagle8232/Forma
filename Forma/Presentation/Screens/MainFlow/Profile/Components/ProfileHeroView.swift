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

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                avatarView
                nameBlock
            }
        }
        .padding(.horizontal, AppSpacing.sectionGap)
        .padding(.top, AppSpacing.sectionGap)
    }

    // MARK: - Avatar

    private var avatarView: some View {
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
                Text(initials)
                    .font(AppFont.display(24))
                    .foregroundColor(AppColor.textPrimary)
            }
        }
        .frame(width: 72, height: 72)
    }

    // MARK: - Name block

    private var nameBlock: some View {
        Text(viewModel.displayName)
            .font(AppFont.display(28))
            .foregroundColor(AppColor.textPrimary)
            .multilineTextAlignment(.center)
    }

    // MARK: - Helpers

    private var initials: String {
        let parts = viewModel.displayName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }
}
