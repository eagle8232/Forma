import SwiftUI

struct AccentIconBadge: View {
    let icon: String
    var size: CGFloat
    var iconSize: CGFloat
    var accent: Color
    var backgroundOpacity: Double
    var borderOpacity: Double

    init(
        icon: String,
        size: CGFloat = 36,
        iconSize: CGFloat = 14,
        accent: Color = AppColor.accentPrimary,
        backgroundOpacity: Double = 0.1,
        borderOpacity: Double = 0.2
    ) {
        self.icon = icon
        self.size = size
        self.iconSize = iconSize
        self.accent = accent
        self.backgroundOpacity = backgroundOpacity
        self.borderOpacity = borderOpacity
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(accent.opacity(backgroundOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accent.opacity(borderOpacity), lineWidth: AppSize.hairline)
                )
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .ultraLight))
                .foregroundStyle(accent.opacity(0.75))
        }
    }
}

struct IconBadgeStyle: ButtonStyle {
    var icon: String
    var size: CGFloat
    var iconSize: CGFloat
    var accent: Color

    func makeBody(configuration: Configuration) -> some View {
        AccentIconBadge(
            icon: icon,
            size: size,
            iconSize: iconSize,
            accent: accent
        )
        .opacity(configuration.isPressed ? 0.7 : 1.0)
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
