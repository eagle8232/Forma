import SwiftUI

struct AccentBadge: View {
    let text: String
    var color: Color
    var fontSize: CGFloat
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var cornerRadius: CGFloat

    init(
        text: String,
        color: Color = AppColor.accentPrimary,
        fontSize: CGFloat = 9,
        horizontalPadding: CGFloat = 9,
        verticalPadding: CGFloat = 4,
        cornerRadius: CGFloat = AppRadius.tag
    ) {
        self.text = text
        self.color = color
        self.fontSize = fontSize
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .medium))
            .tracking(AppTracking.sectionLabel)
            .foregroundStyle(color.opacity(0.65))
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color.opacity(0.18), lineWidth: AppSize.hairline)
                    )
            )
    }
}

struct AccentPill: View {
    let icon: String?
    let text: String
    var color: Color
    var iconSize: CGFloat
    var fontSize: CGFloat

    init(
        icon: String? = nil,
        text: String,
        color: Color = AppColor.accentPrimary,
        iconSize: CGFloat = 9,
        fontSize: CGFloat = 9
    ) {
        self.icon = icon
        self.text = text
        self.color = color
        self.iconSize = iconSize
        self.fontSize = fontSize
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Text(icon)
                    .font(.system(size: iconSize))
            }
            Text(text)
                .font(.system(size: fontSize, weight: .medium))
                .tracking(AppTracking.sectionLabel)
        }
        .foregroundStyle(color.opacity(0.6))
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.08))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.18), lineWidth: AppSize.hairline)
                )
        )
    }
}
