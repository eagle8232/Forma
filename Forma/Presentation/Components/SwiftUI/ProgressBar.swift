import SwiftUI

struct AnimatedProgressBar: View {
    let progress: Double
    var height: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat

    init(
        progress: Double,
        height: CGFloat = 6,
        backgroundColor: Color = AppColor.surfaceFill,
        foregroundColor: Color = AppColor.accentPrimary,
        cornerRadius: CGFloat = 3
    ) {
        self.progress = progress
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(foregroundColor)
                    .frame(width: max(0, min(geometry.size.width * progress, geometry.size.width)), height: height)
                    .animation(.easeInOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: height)
    }
}

struct ProgressBarView: View {
    let value: Double
    let maxValue: Double
    var height: CGFloat
    var color: Color

    init(
        value: Double,
        maxValue: Double = 1.0,
        height: CGFloat = 4,
        color: Color = AppColor.accentPrimary
    ) {
        self.value = value
        self.maxValue = maxValue
        self.height = height
        self.color = color
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColor.surfaceFill)
                    .frame(height: height)

                Capsule()
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(value / maxValue), height: height)
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: height)
    }
}
