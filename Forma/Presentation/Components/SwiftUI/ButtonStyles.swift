import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat
    var opacity: CGFloat
    var animation: Animation

    init(
        scale: CGFloat = 0.98,
        opacity: CGFloat = 0.85,
        animation: Animation = AppAnimation.press
    ) {
        self.scale = scale
        self.opacity = opacity
        self.animation = animation
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .animation(animation, value: configuration.isPressed)
    }
}

struct CardButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.99
    var opacity: CGFloat = 0.9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? opacity : 1.0)
            .animation(AppAnimation.spring, value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
