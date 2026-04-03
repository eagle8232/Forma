import SwiftUI

struct IconCircleButton: View {
    let icon: String
    let size: CGFloat
    let iconSize: CGFloat
    var foregroundColor: Color
    var backgroundColor: Color
    var borderColor: Color

    init(
        icon: String,
        size: CGFloat = 36,
        iconSize: CGFloat = 14,
        foregroundColor: Color = .white.opacity(0.45),
        backgroundColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder
    ) {
        self.icon = icon
        self.size = size
        self.iconSize = iconSize
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: iconSize, weight: .ultraLight))
            .foregroundStyle(foregroundColor)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor)
                    .overlay(Circle().stroke(borderColor, lineWidth: AppSize.hairline))
            )
    }
}

struct IconCircleButtonStyle: ButtonStyle {
    var icon: String
    var size: CGFloat = 36
    var iconSize: CGFloat = 14
    var foregroundColor: Color = .white.opacity(0.45)
    var backgroundColor: Color = AppColor.surfaceFill
    var borderColor: Color = AppColor.surfaceBorder
    var action: () -> Void = {}

    func makeBody(configuration: Configuration) -> some View {
        IconCircleButton(
            icon: icon,
            size: size,
            iconSize: iconSize,
            foregroundColor: configuration.isPressed ? foregroundColor.opacity(0.7) : foregroundColor,
            backgroundColor: backgroundColor,
            borderColor: borderColor
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
