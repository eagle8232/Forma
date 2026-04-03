import SwiftUI

struct FormaCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var fillOpacity: Double
    var borderOpacity: Double

    init(
        cornerRadius: CGFloat = AppRadius.cardLg,
        fillOpacity: Double = 0.035,
        borderOpacity: Double = 0.08,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.fillOpacity = fillOpacity
        self.borderOpacity = borderOpacity
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(fillOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: AppSize.hairline)
            )
    }
}

struct FormaCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var fillOpacity: Double
    var borderOpacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(fillOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: AppSize.hairline)
            )
    }
}

extension View {
    func formaCard(
        cornerRadius: CGFloat = AppRadius.cardLg,
        fillOpacity: Double = 0.035,
        borderOpacity: Double = 0.08
    ) -> some View {
        modifier(FormaCardModifier(cornerRadius: cornerRadius, fillOpacity: fillOpacity, borderOpacity: borderOpacity))
    }
}
