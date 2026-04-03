import SwiftUI

struct SurfaceCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat
    var fillColor: Color
    var borderColor: Color

    init(
        cornerRadius: CGFloat = AppRadius.cardLg,
        padding: CGFloat = 0,
        fillColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.fillColor = fillColor
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: AppSize.hairline)
                    )
            )
    }
}

struct SurfaceCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var padding: CGFloat
    var fillColor: Color
    var borderColor: Color

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: AppSize.hairline)
                    )
            )
    }
}

extension View {
    func surfaceCard(
        cornerRadius: CGFloat = AppRadius.cardLg,
        padding: CGFloat = 0,
        fillColor: Color = AppColor.surfaceFill,
        borderColor: Color = AppColor.surfaceBorder
    ) -> some View {
        modifier(SurfaceCardModifier(cornerRadius: cornerRadius, padding: padding, fillColor: fillColor, borderColor: borderColor))
    }
}
