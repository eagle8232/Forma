import SwiftUI

struct SuggestionChip: View {
    let text: String
    var font: Font
    var textColor: Color
    var backgroundColor: Color
    var borderColor: Color
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat

    init(
        text: String,
        font: Font = .system(size: 13, weight: .regular),
        textColor: Color = .white.opacity(0.45),
        backgroundColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder,
        horizontalPadding: CGFloat = 14,
        verticalPadding: CGFloat = 9
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        Text(text)
            .font(font)
            .tracking(AppTracking.body)
            .foregroundStyle(textColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(
                Capsule()
                    .fill(backgroundColor)
                    .overlay(
                        Capsule()
                            .stroke(borderColor, lineWidth: AppSize.hairline)
                    )
            )
    }
}

struct TextChip: View {
    let text: String
    var font: Font
    var textColor: Color
    var backgroundColor: Color
    var borderColor: Color

    init(
        text: String,
        font: Font = .system(size: 12, weight: .regular),
        textColor: Color = .white.opacity(0.45),
        backgroundColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder
    ) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(textColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(borderColor, lineWidth: AppSize.hairline)
                    )
            )
    }
}

struct TagChip: View {
    let text: String
    var color: Color

    init(text: String, color: Color = AppColor.accentPrimary) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .medium))
            .tracking(1.5)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }
}
