import SwiftUI

struct FormaDivider: View {
    var color: Color
    var height: CGFloat
    var leadingPadding: CGFloat

    init(
        color: Color = AppColor.border,
        height: CGFloat = 1,
        leadingPadding: CGFloat = 68
    ) {
        self.color = color
        self.height = height
        self.leadingPadding = leadingPadding
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .padding(.leading, leadingPadding)
    }
}

struct FormaHairline: View {
    var color: Color

    init(color: Color = AppColor.border) {
        self.color = color
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: AppSize.hairline)
    }
}
