//
//  AIActionCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct AIActionCard: View {

    let title:      String
    let subtitle:   String
    let systemIcon: String
    var accent:     Color = AppColor.accentPrimary
    var onTap:      (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 12) {

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(accent.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(accent.opacity(0.2), lineWidth: AppSize.hairline)
                        )
                        .frame(width: 36, height: 36)

                    Image(systemName: systemIcon)
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundStyle(accent.opacity(0.75))
                }

                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .customFont(.label)
                        .foregroundStyle(AppColor.textPrimary)

                    Text(subtitle)
                        .customFont(.microTracked)
                        .tracking(AppTracking.body)
                        .foregroundStyle(AppColor.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(AppColor.surfaceFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.card)
                            .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                    )
            )
        }
        .buttonStyle(AIActionCardStyle())
    }
}

private struct AIActionCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(AppAnimation.press, value: configuration.isPressed)
    }
}
