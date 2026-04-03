import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String?
    var action: (() -> Void)?
    var iconColor: Color
    var iconBackgroundColor: Color

    init(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color = .white.opacity(0.3),
        iconBackgroundColor: Color = AppColor.surfaceFill
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.iconBackgroundColor = iconBackgroundColor
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .ultraLight))
                    .foregroundStyle(iconColor)
            }

            VStack(spacing: 6) {
                Text(title)
                    .customFont(.heading2)
                    .foregroundStyle(AppColor.textPrimary)

                Text(subtitle)
                    .customFont(.bodySmall)
                    .foregroundStyle(AppColor.textTertiary)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .customFont(.microTracked)
                        .tracking(AppTracking.sectionLabel)
                        .foregroundStyle(AppColor.accentPrimary.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppColor.surfaceFill)
                                .overlay(
                                    Capsule()
                                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct EmptyIconCircle: View {
    let icon: String
    var size: CGFloat
    var iconSize: CGFloat
    var backgroundColor: Color
    var borderColor: Color
    var iconColor: Color

    init(
        icon: String,
        size: CGFloat = 56,
        iconSize: CGFloat = 20,
        backgroundColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder,
        iconColor: Color = .white.opacity(0.3)
    ) {
        self.icon = icon
        self.size = size
        self.iconSize = iconSize
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.iconColor = iconColor
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .overlay(Circle().stroke(borderColor, lineWidth: AppSize.hairline))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .ultraLight))
                .foregroundStyle(iconColor)
        }
    }
}
