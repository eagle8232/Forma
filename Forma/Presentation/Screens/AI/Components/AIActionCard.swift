//
//  AIActionCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct AIActionCard: View {
    let title: String
    let subtitle: String
    let systemIcon: String
    var accent: Color = AppColor.accentPrimary
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 12) {
                AccentIconBadge(
                    icon: systemIcon,
                    accent: accent,
                    backgroundOpacity: 0.1,
                    borderOpacity: 0.2
                )

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

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .surfaceCard(cornerRadius: AppRadius.card, padding: 0)
        .buttonStyle(CardButtonStyle())
    }
}
